From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Forbid linking to devices that
 have uppers
Date: Fri, 01 Sep 2017 10:00:34 -0700 (PDT)
Message-ID: <20170901.100034.224684373888616212.davem@davemloft.net>
References: <20170901085231.1396-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, nogahf@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbdIARAf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:00:35 -0400
In-Reply-To: <20170901085231.1396-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  1 Sep 2017 10:52:31 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> The mlxsw driver relies on NETDEV_CHANGEUPPER events to configure the
> device in case a port is enslaved to a master netdev such as bridge or
> bond.
> 
> Since the driver ignores events unrelated to its ports and their
> uppers, it's possible to engineer situations in which the device's data
> path differs from the kernel's.
> 
> One example to such a situation is when a port is enslaved to a bond
> that is already enslaved to a bridge. When the bond was enslaved the
> driver ignored the event - as the bond wasn't one of its uppers - and
> therefore a bridge port instance isn't created in the device.
> 
> Until such configurations are supported forbid them by checking that the
> upper device doesn't have uppers of its own.
> 
> Fixes: 0d65fc13042f ("mlxsw: spectrum: Implement LAG port join/leave")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Nogah Frankel <nogahf@mellanox.com>
> Tested-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks.
