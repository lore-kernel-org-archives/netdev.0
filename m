From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Wed, 8 Dec 2010 17:24:32 +0800
Message-ID: <20101208092432.GA15610@gondor.apana.org.au>
References: <1291717744-30111-1-git-send-email-martin@strongswan.org> <1291717744-30111-3-git-send-email-martin@strongswan.org> <20101208084954.GA15252@gondor.apana.org.au> <1291800041.2005.25.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291800041.2005.25.camel@martin>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2010 at 10:20:41AM +0100, Martin Willi wrote:
> 
> > In particular, why would we need a boundary at all? Setting it to
> > anything other than the PMTU would seem to defeat the purpose of
> > TFC for packets between the boundary and the PMTU.
> 
> I don't agree, this highly depends on the traffic on the SA. For a
> general purpose tunnel with TCP flows, PMTU padding is fine. But if
> there are only small packets (maybe SIP+RTP), padding to the PMTU is
> very expensive.
> 
> The administrator setting up the SAs probably knows (or even controls
> directly) what traffic it is used for, and might lower the boundary
> accordingly.

OK, that's a good reason.

But you should probably get rid of that unused flag field in
the user-interface and just provide a pad length.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
