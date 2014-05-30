From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Reset RoCE VF gids when guest
 driver goes down
Date: Fri, 30 May 2014 16:58:22 -0700 (PDT)
Message-ID: <20140530.165822.292594586292656620.davem@davemloft.net>
References: <1401171998-22702-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaE3X6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 19:58:23 -0400
In-Reply-To: <1401171998-22702-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 27 May 2014 09:26:38 +0300

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> Reset the GIDs assigned to a VF in the port RoCE GID table when
> that guest goes down (either crashes or goes down cleanly).
> 
> As part of this fix, we refactor the RoCE gid table driver copy,
> moving it to the mlx4_port_info structure (together with the MAC
> and VLAN tables).
> 
> As with the MAC and VLAN tables, we now use a mutex per port
> for the GID table so that modifying the driver copy and
> modifying the firmware copy of a port GID table becomes an 
> atomic operation (thus avoiding driver-copy/FW-copy mismatches).
> 
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
