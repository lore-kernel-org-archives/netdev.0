From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Wed, 21 Nov 2007 21:42:58 +0800
Message-ID: <20071121134258.GA30883@gondor.apana.org.au>
References: <20071121124532.GA17263@havoc.gtf.org> <20071121.222051.94402865.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3268 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752564AbXKUNnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 08:43:22 -0500
Content-Disposition: inline
In-Reply-To: <20071121.222051.94402865.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 01:20:51PM +0000, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20071121124532.GA17263@havoc.gtf.org> (at Wed, 21 Nov 200=
7 07:45:32 -0500), Jeff Garzik <jeff@garzik.org> says:
>=20
> >=20
> > SO_NO_CHECK support for IPv6 appeared to be missing. This is presen=
ted,
> > based on a reading of net/ipv4/udp.c.
>=20
> Disagree. UDP checksum is mandatory in IPv6.

Right, IPv6 doesn't have a header checksum so the UDP checksum
must be there.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
