From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 11/12] [IPSEC]: Reinject packet instead of calling netfilter directly on input
Date: Tue, 16 Oct 2007 23:12:47 +0800
Message-ID: <20071016151247.GA13103@gondor.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au> <E1IhnTz-0003HT-00@gondolin.me.apana.org.au> <20071017.000547.102039099.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	kozakai@linux-ipv6.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3202 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933385AbXJPPMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 11:12:50 -0400
Content-Disposition: inline
In-Reply-To: <20071017.000547.102039099.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 12:05:47AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>=20
> I think with this change, we parse extension headers, twice.
> We really do not want to do this.

Good point.  I'll need to think of some other way to do this then.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
