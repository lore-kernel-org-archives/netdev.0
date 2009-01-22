From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 18:39:46 +1100
Message-ID: <20090122073946.GB12395@gondor.apana.org.au>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44008 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753150AbZAVHjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 02:39:52 -0500
Content-Disposition: inline
In-Reply-To: <4978180A.6080304@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 08:54:02AM +0200, Timo Ter=E4s wrote:
>
> That ipsec-tools feature works on *BSD. Works on Linux too
> as kernel does not (yet) use that for anything except reporting
> it back. Other OSes might use it already to e.g. fix-up the
> packet checksums in transport mode SAs; I believe Linux just
> recalculates the checksum.

Right, the reason nobody has noticed is because transport mode
NAT-T is inherently insecure (and difficult to deploy if you have
multiple peers behind one gateway) so nobody uses it in the field.

So I think there is even less reason to do this for af_key.

If you don't have the time to convert racoon, couldn't you look
at one of the *swans and use that as the basis of your work?

> The future patch I have in my mind I've been talking about,
> does make use of NAT-OA. So that's why I noticed it only
> just now. Btw, could someone comment on the idea of passing
> NAT-OA to neighbour cache and make xfrm use it when choosing
> which xfrm state to use?

I'm concerned about using NAT-OA for anything policy related
because it is impossible to authenticate or verify.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
