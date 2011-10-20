From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fix skb truesize underestimation
Date: Thu, 20 Oct 2011 05:23:47 -0400 (EDT)
Message-ID: <20111020.052347.1870609945870415446.davem@davemloft.net>
References: <1319101223.3781.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756177Ab1JTJXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 05:23:51 -0400
In-Reply-To: <1319101223.3781.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 11:00:23 +0200

> bnx2x allocates a full page per fragment.
> 
> We must account in skb->truesize, the size of the fragment, not the used
> part of it.
>     
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

Applied.
