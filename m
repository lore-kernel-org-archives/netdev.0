From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlxsw: switchib: add MLXSW_PCI dependency
Date: Fri, 18 Nov 2016 14:13:26 -0500 (EST)
Message-ID: <20161118.141326.1186329701317224000.davem@davemloft.net>
References: <20161118160127.473555-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, ivecera@redhat.com,
        eladr@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161118160127.473555-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Nov 2016 17:01:14 +0100

> The newly added switchib driver fails to link if MLXSW_PCI=m:
> 
> drivers/net/ethernet/mellanox/mlxsw/mlxsw_switchib.o: In function^Cmlxsw_sib_module_exit':
> switchib.c:(.exit.text+0x8): undefined reference to `mlxsw_pci_driver_unregister'
> switchib.c:(.exit.text+0x10): undefined reference to `mlxsw_pci_driver_unregister'
> drivers/net/ethernet/mellanox/mlxsw/mlxsw_switchib.o: In function `mlxsw_sib_module_init':
> switchib.c:(.init.text+0x28): undefined reference to `mlxsw_pci_driver_register'
> switchib.c:(.init.text+0x38): undefined reference to `mlxsw_pci_driver_register'
> switchib.c:(.init.text+0x48): undefined reference to `mlxsw_pci_driver_unregister'
> 
> The other two such sub-drivers have a dependency, so add the same one
> here. In theory we could allow this driver if MLXSW_PCI is disabled,
> but it's probably not worth it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Please resubmit this with a proper fixes tag that identifies the commit that
added the switchib driver.

Thanks.
