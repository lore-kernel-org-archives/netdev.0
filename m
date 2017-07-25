From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: spectrum_router: Fix build when IPv6
 isn't enabled
Date: Mon, 24 Jul 2017 17:15:40 -0700 (PDT)
Message-ID: <20170724.171540.1740509445778265155.davem@davemloft.net>
References: <20170724075600.2798-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdGYAPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:15:44 -0400
In-Reply-To: <20170724075600.2798-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 24 Jul 2017 09:56:00 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When IPv6 isn't enabled the following error is generated:
> 
> ERROR: "nd_tbl" [drivers/net/ethernet/mellanox/mlxsw/mlxsw_spectrum.ko]
> undefined!
> 
> Fix it by replacing 'arp_tbl' and 'nd_tbl' with 'tbl->family' wherever
> possible and reference 'nd_tbl' only when IPV6 is enabled.
> 
> Fixes: d5eb89cf68d6 ("mlxsw: spectrum_router: Reflect IPv6 neighbours to the device")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
