From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPSEC]: Change the ICV length of sha256 to 128 bits
Date: Tue, 30 Dec 2008 07:47:50 +1100
Message-ID: <20081229204750.GA13680@gondor.apana.org.au>
References: <20081224060225.GA26084@obsidianresearch.com> <20081224085940.GA24830@gondor.apana.org.au> <20081224183355.GB26084@obsidianresearch.com> <1230555919.6644.36.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56659 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751713AbYL2UsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 15:48:01 -0500
Content-Disposition: inline
In-Reply-To: <1230555919.6644.36.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2008 at 02:05:19PM +0100, Martin Willi wrote:
>
> =EF=BB=BFIn PF_KEY, SADB_X_AALG_SHA2_256HMAC (5) was defined in
> draft-ietf-ipsec-ciph-sha-256-00 to 96 bit truncation (what is curren=
tly
> implemented). draft-ietf-ipsec-ciph-sha-256-01 defined it to 128 bit
> truncation (what is now RFC 4868).
> Those numbers starting from 12 are IKEv2 algorithm identifiers and ar=
e
> never passed to the kernel.

What are you talking about? Neither of those two drafts talks
about the ID used between the KM and the kernel.  So the PF_KEY
ID is simply irrelevant.

What is important though is what's deployed in the field with
respect to IKE.  All the BSDs support 96-bit truncation so we
should continue to do that as well.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
