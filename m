From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ucc_geth, increase no. of HW RX descriptors
Date: Wed, 02 Nov 2011 00:56:50 -0400 (EDT)
Message-ID: <20111102.005650.1042174729471815202.davem@davemloft.net>
References: <1319548630-6561-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1KBE45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 00:56:57 -0400
In-Reply-To: <1319548630-6561-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Tue, 25 Oct 2011 15:17:10 +0200

> In a busy network we see ucc_geth is dropping RX pkgs every now
> and then. Increase the first RX queues HW descriptors from
> 16 to 32 to deal with this.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

1) This patch doesn't apply, because in the current tree this
   dirver lives under drivers/net/ethernet/freescale/ not
   drivers/net

2) Why not increase RX_BD_RING_LEN and thus all the ring sizes,
   is there a special reason only the first ring's size should
   be increased?

   Because the way you've made this change is confusing, someone
   will see RX_BD_RING_LEN's definition and believe that this is
   the size of the primary ring unless they happen to notice
   how .bdRingLenRx is initialized in this special way.

Thus, this patch needs changes before it can even be considered
for inclusion.
