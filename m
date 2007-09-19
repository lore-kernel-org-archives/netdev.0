From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH 3/3] [PPP] L2TP: Fix skb handling in pppol2tp_xmit
Date: Thu, 20 Sep 2007 01:11:14 +0200
Message-ID: <20070919231114.GC30564@stusta.de>
References: <46F032D5.7020806@katalix.com> <20070918.133240.35800852.davem@davemloft.net> <20070919013018.GB15046@gondor.apana.org.au> <20070919.104513.71087294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: herbert@gondor.apana.org.au, jchapman@katalix.com,
	mostrows@speakeasy.net, paulus@samba.org, toralf.foerster@gmx.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:40126 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751489AbXISXLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 19:11:01 -0400
Content-Disposition: inline
In-Reply-To: <20070919.104513.71087294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 10:45:13AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 19 Sep 2007 09:30:18 +0800
> 
> > [PPP] pppoe: Fix double-free on skb after transmit failure
> > 
> > When I got rid of the second packet in __pppoe_xmit I created
> > a double-free on the skb because of the goto abort on failure.
> > This patch removes that.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied.

Please excuse in case this was already clear, but since this regression 
made it into Linus' tree it should be fixed there before 2.6.23.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

