From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: switchib:  add MLXSW_PCI dependency
Date: Mon, 21 Nov 2016 12:20:11 +0100
Message-ID: <20161121112011.GB1739@nanopsycho>
References: <20161118160127.473555-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ivan Vecera <ivecera@redhat.com>,
        Elad Raz <eladr@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161118160127.473555-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Nov 18, 2016 at 05:01:14PM CET, arnd@arndb.de wrote:
>The newly added switchib driver fails to link if MLXSW_PCI=m:
>
>drivers/net/ethernet/mellanox/mlxsw/mlxsw_switchib.o: In function^Cmlxsw_sib_module_exit':
>switchib.c:(.exit.text+0x8): undefined reference to `mlxsw_pci_driver_unregister'
>switchib.c:(.exit.text+0x10): undefined reference to `mlxsw_pci_driver_unregister'
>drivers/net/ethernet/mellanox/mlxsw/mlxsw_switchib.o: In function `mlxsw_sib_module_init':
>switchib.c:(.init.text+0x28): undefined reference to `mlxsw_pci_driver_register'
>switchib.c:(.init.text+0x38): undefined reference to `mlxsw_pci_driver_register'
>switchib.c:(.init.text+0x48): undefined reference to `mlxsw_pci_driver_unregister'
>
>The other two such sub-drivers have a dependency, so add the same one
>here. In theory we could allow this driver if MLXSW_PCI is disabled,
>but it's probably not worth it.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
