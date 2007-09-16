From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [NET] skbuff: Add skb_cow_head
Date: Sun, 16 Sep 2007 16:21:28 -0700 (PDT)
Message-ID: <20070916.162128.51862958.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2V9-0007NM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753930AbXIPXV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:21:28 -0400
In-Reply-To: <E1IR2V9-0007NM-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:09:15 +0800

> [NET] skbuff: Add skb_cow_head
> 
> This patch adds an optimised version of skb_cow that avoids the copy if
> the header can be modified even if the rest of the payload is cloned.
> 
> This can be used in encapsulating paths where we only need to modify the
> header.  As it is, this can be used in PPPOE and bridging.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
