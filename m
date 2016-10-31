From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Fix incorrect reuse of MID entries
Date: Mon, 31 Oct 2016 15:36:06 -0400 (EDT)
Message-ID: <20161031.153606.989406936490082438.davem@davemloft.net>
References: <1477818562-30185-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945866AbcJaTgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:36:08 -0400
In-Reply-To: <1477818562-30185-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 30 Oct 2016 10:09:22 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> In the device, a MID entry represents a group of local ports, which can
> later be bound to a MDB entry.
> 
> The lookup of an existing MID entry is currently done using the provided
> MC MAC address and VID, from the Linux bridge. However, this can result
> in an incorrect reuse of the same MID index in different VLAN-unaware
> bridges (same IP MC group and VID 0).
> 
> Fix this by performing the lookup based on FID instead of VID, which is
> unique across different bridges.
> 
> Fixes: 3a49b4fde2a1 ("mlxsw: Adding layer 2 multicast support")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Acked-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, should I queue this up for -stable?
