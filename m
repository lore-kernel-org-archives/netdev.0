From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_router: Only handle IPv4 and IPv6
 events
Date: Sat, 16 Sep 2017 09:22:13 -0700 (PDT)
Message-ID: <20170916.092213.1078128003318643733.davem@davemloft.net>
References: <20170915133107.1258-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, flokli@flokli.de,
        andreas@rammhold.de, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51748 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbdIPQWO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 12:22:14 -0400
In-Reply-To: <20170915133107.1258-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 15 Sep 2017 15:31:07 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> The driver doesn't support events from address families other than IPv4
> and IPv6, so ignore them. Otherwise, we risk queueing a work item before
> it's initialized.
> 
> This can happen in case a VRF is configured when MROUTE_MULTIPLE_TABLES
> is enabled, as the VRF driver will try to add an l3mdev rule for the
> IPMR family.
> 
> Fixes: 65e65ec137f4 ("mlxsw: spectrum_router: Don't ignore IPv6 notifications")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Andreas Rammhold <andreas@rammhold.de>
> Reported-by: Florian Klink <flokli@flokli.de>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
