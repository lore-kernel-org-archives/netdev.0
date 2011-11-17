From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2: switch to build_skb() infrastructure
Date: Thu, 17 Nov 2011 16:04:21 -0500 (EST)
Message-ID: <20111117.160421.2203345120962009703.davem@davemloft.net>
References: <1321378205.2856.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab1KQVEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:04:24 -0500
In-Reply-To: <1321378205.2856.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Nov 2011 18:30:05 +0100

> This is very similar to bnx2x conversion, but bnx2 only requires 16bytes
> alignement at start of the received frame to store its l2_fhdr, so goal
> was not to reduce skb truesize (in fact it should not change after this
> patch)
> 
> Using build_skb() reduces cache line misses in the driver, since we
> use cache hot skb instead of cold ones. Number of in-flight sk_buff
> structures is lower, they are more likely recycled in SLUB caches
> while still hot.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

Broadcom folks, please review.
