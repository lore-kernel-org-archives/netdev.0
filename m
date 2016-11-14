From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_router: Flush FIB tables during
 fini
Date: Mon, 14 Nov 2016 16:46:03 -0500 (EST)
Message-ID: <20161114.164603.1372656156922013373.davem@davemloft.net>
References: <1479119192-1545-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752729AbcKNVqF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 16:46:05 -0500
In-Reply-To: <1479119192-1545-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 14 Nov 2016 11:26:32 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Since commit b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications
> instead of switchdev calls") we reflect to the device the entire FIB
> table and not only FIBs that point to netdevs created by the driver.
> 
> During module removal, FIBs of the second type are removed following
> NETDEV_UNREGISTER events sent. The other FIBs are still present in both
> the driver's cache and the device's table.
> 
> Fix this by iterating over all the FIB tables in the device and flush
> them. There's no need to take locks, as we're the only writer.
> 
> Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
