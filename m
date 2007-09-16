From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [PPP] generic: Call skb_cow_head before scribbling
 over skb
Date: Sun, 16 Sep 2007 16:21:53 -0700 (PDT)
Message-ID: <20070916.162153.52133374.davem@davemloft.net>
References: <20070831090625.GA28175@gondor.apana.org.au>
	<E1IR2VA-0007NU-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60850
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753805AbXIPXVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:21:53 -0400
In-Reply-To: <E1IR2VA-0007NU-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 17:09:16 +0800

> [PPP] generic: Call skb_cow_head before scribbling over skb
> 
> It's rude to write over data that other people are still using.  So call
> skb_cow_head before PPP proceeds to modify the skb data.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
