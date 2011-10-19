From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix a potential skb leak in l2tp_xmit_skb()
Date: Tue, 18 Oct 2011 23:32:22 -0400 (EDT)
Message-ID: <20111018.233222.1625558531315885753.davem@davemloft.net>
References: <1318001746.3207.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab1JSDcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:32:25 -0400
In-Reply-To: <1318001746.3207.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Oct 2011 17:35:46 +0200

> l2tp_xmit_skb() can leak one skb if skb_cow_head() returns an error.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks Eric.
