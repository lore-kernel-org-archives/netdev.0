From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Mark split ports as such
Date: Sat, 17 Dec 2016 21:45:11 -0500 (EST)
Message-ID: <20161217.214511.989596544518526060.davem@davemloft.net>
References: <1481912943-2864-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        tamirw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752056AbcLRCpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 21:45:13 -0500
In-Reply-To: <1481912943-2864-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 16 Dec 2016 19:29:03 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When a port is split we should mark it as such, as otherwise the split
> ports aren't renamed correctly (e.g. sw1p3 -> sw1p3s1) and the unsplit
> operation fails:
> 
> $ devlink port split sw1p3 count 4
> $ devlink port unsplit eth0
> devlink answers: Invalid argument
> [  598.565307] mlxsw_spectrum 0000:03:00.0 eth0: Port wasn't split
> 
> Fixes: 67963a33b4fd ("mlxsw: Make devlink port instances independent of spectrum/switchx2 port instances")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Tamir Winetroub <tamirw@mellanox.com>
> Reviewed-by: Elad Raz <eladr@mellanox.com>
> Tested-by: Tamir Winetroub <tamirw@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
