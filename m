From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1328/1341]
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:77:3: error:
 'devlink_dpipe_header_ethernet' undeclared here (not in a function)
Date: Thu, 24 Aug 2017 18:11:50 -0700 (PDT)
Message-ID: <20170824.181150.1024909235376525254.davem@davemloft.net>
References: <201708250859.0ROh3FDk%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arkadis@mellanox.com, kbuild-all@01.org, netdev@vger.kernel.org,
        jiri@mellanox.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754298AbdHYBLv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:11:51 -0400
In-Reply-To: <201708250859.0ROh3FDk%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Fri, 25 Aug 2017 08:16:01 +0800

> All error/warnings (new ones prefixed by >>):
> 
>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:77:3: error: 'devlink_dpipe_header_ethernet' undeclared here (not in a function)
>      &devlink_dpipe_header_ethernet,
>       ^
>>> drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:78:3: error: 'devlink_dpipe_header_ipv4' undeclared here (not in a function)
>      &devlink_dpipe_header_ipv4,
>       ^
>    drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c: In function 'mlxsw_sp_dpipe_erif_table_init':
>    drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c:305:9: error: too few arguments to function 'devlink_dpipe_table_register'
>      return devlink_dpipe_table_register(devlink,

Jiri and co., I think you'll need some ifdef'ery to deal with this
properly.
