From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Tue, 05 Nov 2013 21:20:22 -0800
Message-ID: <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106040717.GA15711@gondor.apana.org.au>
	 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106042858.GA15745@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35136 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3KFFUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 00:20:24 -0500
Received: by mail-pd0-f181.google.com with SMTP id x10so9579533pdj.40
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 21:20:23 -0800 (PST)
In-Reply-To: <20131106042858.GA15745@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 12:28 +0800, Herbert Xu wrote:
> On Tue, Nov 05, 2013 at 08:23:05PM -0800, Eric Dumazet wrote:
> >
> > Nope, I already mentioned this :
> > 
> > Please take a look at 2613af0ed18a11d5c566a81f9a6510b73180660a
> > ("virtio_net: migrate mergeable rx buffers to page frag allocators")
> 
> This patch should simply be reverted.  You guys steam-rolled over
> the virtio_net people's concerns that this seriously impacts virt
> performance.
> 

Have you followed netdev traffic lately ?

virtio_net performance is better than before, and we did no revert,
thank you.

I am really tired, I'll fix skb_segment() tomorrow.
