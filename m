From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Wed, 19 Sep 2007 16:12:16 -0700 (PDT)
Message-ID: <20070919.161216.61337834.davem@davemloft.net>
References: <20070919013018.GB15046@gondor.apana.org.au>
	<20070919.104513.71087294.davem@davemloft.net>
	<20070919231114.GC30564@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jchapman@katalix.com,
	mostrows@speakeasy.net, paulus@samba.org, toralf.foerster@gmx.de,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750990AbXISXMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:12:17 -0400
In-Reply-To: <20070919231114.GC30564@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Thu, 20 Sep 2007 01:11:14 +0200

> On Wed, Sep 19, 2007 at 10:45:13AM -0700, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Wed, 19 Sep 2007 09:30:18 +0800
> > 
> > > [PPP] pppoe: Fix double-free on skb after transmit failure
> > > 
> > > When I got rid of the second packet in __pppoe_xmit I created
> > > a double-free on the skb because of the goto abort on failure.
> > > This patch removes that.
> > > 
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Applied.
> 
> Please excuse in case this was already clear, but since this regression 
> made it into Linus' tree it should be fixed there before 2.6.23.

I will make sure this happens.

I'm just waiting for Alexey to test the SFQ crash fix and
then I'll send everything queued.
