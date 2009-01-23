From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Fri, 23 Jan 2009 20:09:59 +1100
Message-ID: <20090123090959.GA27244@gondor.apana.org.au>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <49796139.3090605@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36662 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755316AbZAWJKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 04:10:07 -0500
Content-Disposition: inline
In-Reply-To: <49796139.3090605@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2009 at 08:18:33AM +0200, Timo Ter=E4s wrote:
=2E
> If you still consider that the copying of that extension is
> inappropriate then maybe memset():ing the encap_oa to zero
> would be acceptable?

Yes I think doing the memset/zero assignment is not only reasonable
but a requirement since it has security implications.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
