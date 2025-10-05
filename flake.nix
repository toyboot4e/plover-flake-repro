{
  description = "plover-flake #263 repro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plover-flake.url = "github:openstenoproject/plover-flake";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      plover-flake,
      ...
    }:
    {
      nixosConfigurations.test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          {
            system.stateVersion = "25.11";

            networking.hostName = "test";
            users.users.test = {
              isNormalUser = true;
              initialPassword = "test";
              extraGroups = [
                "dialout"
                "input"
                "wheel" # sudo
              ];
            };

            services.xserver.enable = true;
            services.xserver.desktopManager.xfce.enable = true;
          }

          home-manager.nixosModules.home-manager

          {
            home-manager.users.test =
              { pkgs, ... }:
              {
                imports = [ inputs.plover-flake.homeManagerModules.plover ];
                home.stateVersion = "25.11";
                programs.plover = {
                  enable = true;
                  package = plover-flake.packages.${pkgs.system}.plover-full;
                  settings = {
                    "Plugins" = {
                      enabled_extensions = [
                        "plover_lapwing_aio"
                      ];
                    };
                    "System" = {
                      name = "Lapwing";
                    };
                  };
                };
              };
          }
        ];

      };
    };
}
