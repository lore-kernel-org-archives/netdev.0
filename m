From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] mlxsw: switchib: add MLXSW_PCI dependency
Date: Tue, 29 Nov 2016 20:36:42 -0500 (EST)
Message-ID: <20161129.203642.1125810970021004476.davem@davemloft.net>
References: <20161128142622.2758614-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, vadimp@mellanox.com,
        cera@cera.cz, eladr@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbcK3Bgo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:36:44 -0500
In-Reply-To: <20161128142622.2758614-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 28 Nov 2016 15:26:04 +0100

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
> Fixes: d1ba52638456 ("mlxsw: switchib: Introduce SwitchIB and SwitchIB silicon driver")
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> v2: add Fixes tag

Applied, thanks Arnd.
