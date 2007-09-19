From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Wed, 19 Sep 2007 10:45:13 -0700 (PDT)
Message-ID: <20070919.104513.71087294.davem@davemloft.net>
References: <46F032D5.7020806@katalix.com>
	<20070918.133240.35800852.davem@davemloft.net>
	<20070919013018.GB15046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, mostrows@speakeasy.net, paulus@samba.org,
	toralf.foerster@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45129
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752826AbXISRpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 13:45:14 -0400
In-Reply-To: <20070919013018.GB15046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 19 Sep 2007 09:30:18 +0800

> [PPP] pppoe: Fix double-free on skb after transmit failure
> 
> When I got rid of the second packet in __pppoe_xmit I created
> a double-free on the skb because of the goto abort on failure.
> This patch removes that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
