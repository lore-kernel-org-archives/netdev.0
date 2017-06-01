From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlxsw: spectrum: Add bridge dependency for
 spectrum
Date: Thu, 01 Jun 2017 15:07:00 -0400 (EDT)
Message-ID: <20170601.150700.1560422855112281074.davem@davemloft.net>
References: <20170531183342.19349-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        nikolay@cumulusnetworks.com, mlxsw@mellanox.com, arnd@arndb.de
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFATHC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 15:07:02 -0400
In-Reply-To: <20170531183342.19349-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Wed, 31 May 2017 21:33:42 +0300

> When BRIDGE is a loadable module, MLXSW_SPECTRUM mustn't be built-in:
> 
> drivers/built-in.o: In function `mlxsw_sp_bridge_device_create':
> drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:145: undefined reference to `br_vlan_enabled'
> drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:158: undefined reference to `br_multicast_enabled'
> drivers/built-in.o: In function `mlxsw_sp_dev_rif_type':
> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:2972: undefined reference to `br_vlan_enabled'
> drivers/built-in.o: In function `mlxsw_sp_inetaddr_vlan_event':
> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:3310: undefined reference to `br_vlan_enabled'
> 
> Add Kconfig dependency to enforce usable configurations.
> 
> Fixes: c57529e1d5d8 ("mlxsw: spectrum: Replace vPorts with Port-VLAN")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Tested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
