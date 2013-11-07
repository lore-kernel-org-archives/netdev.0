From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 19:05:12 -0800
Message-ID: <1383793512.9412.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
	 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383783321.2878.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107011337.GD8144@order.stressinduktion.org>
	 <1383787279.2878.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383788068.2878.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131107020321.GG8144@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35287 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150Ab3KGDFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 22:05:15 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so596653pab.40
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 19:05:14 -0800 (PST)
In-Reply-To: <20131107020321.GG8144@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 03:03 +0100, Hannes Frederic Sowa wrote:

> > Oh yes, I missed a : data_len += remain;
> > 
> > at line 2906 :
> > 
> > 	offset = remain;
> > +	data_len += remain;
> > 	continue;
> 
> Hm, I still hit the WARN_ON_ONCE (same test as above) with this fixed up:
> 

Thanks, I'll track this and send a v2
