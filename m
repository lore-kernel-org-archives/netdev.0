From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 07:06:32 -0800
Message-ID: <1383750392.4291.167.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:32803 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252Ab3KFPGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 10:06:34 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp8so3007009pbb.3
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 07:06:34 -0800 (PST)
In-Reply-To: <20131106143927.GA21604@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 22:39 +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 09:30:45PM +0800, Herbert Xu wrote:
> > 
> > In order to handle malicious GSO packets that is now possible with
> > the use of frag_list in virtio_net, we need to remove the BUG_ONs.
> 
> OK Eric was right and I am a dumb ass.  This has no chance in hell
> of handling the new virtio_net frag_list since we won't have any
> headers in the frag_list skbs.
> 
> In fact, we never relied on the frag_list having headers anyway so
> it's not hard to fix this.
> 
> Still totally untested but at least this has a chance of handling
> the new virtio_net.

OK I'll take a look at this and make tests today, thanks !
