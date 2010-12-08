From: Martin Willi <martin@strongswan.org>
Subject: Re: [PATCH 2/3] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Wed, 08 Dec 2010 10:20:41 +0100
Message-ID: <1291800041.2005.25.camel@martin>
References: <1291717744-30111-1-git-send-email-martin@strongswan.org>
	 <1291717744-30111-3-git-send-email-martin@strongswan.org>
	 <20101208084954.GA15252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20101208084954.GA15252@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> In particular, why would we need a boundary at all? Setting it to
> anything other than the PMTU would seem to defeat the purpose of
> TFC for packets between the boundary and the PMTU.

I don't agree, this highly depends on the traffic on the SA. For a
general purpose tunnel with TCP flows, PMTU padding is fine. But if
there are only small packets (maybe SIP+RTP), padding to the PMTU is
very expensive.

The administrator setting up the SAs probably knows (or even controls
directly) what traffic it is used for, and might lower the boundary
accordingly.

Regards
Martin
