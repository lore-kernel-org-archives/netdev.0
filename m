From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 14:24:59 +0200
Message-ID: <20130530122459.GE2475@ritirata.org>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com>
 <20130528.233647.1209227470109213894.davem@davemloft.net>
 <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com>
 <20130529194438.GY3333@ritirata.org>
 <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com>
 <20130530114556.GC2475@ritirata.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B725B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="HnQK338I3UIa/qiP"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, horms@verge.net.au
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:25755 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab3E3M0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 08:26:50 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B725B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HnQK338I3UIa/qiP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 30, 2013 at 01:22:14PM +0100, David Laight wrote:
> > Of course - we need to look at the value that ALL_ONES()
> > generates in an expression. So the test print needs to be:
> > 	printf("%hhx %hhx %hx %hx %x %x %lx %lx %llx %llx\n",
> > 		ALL_ONES(a), ALL_ONES(b), ALL_ONES(c), ALL_ONES(d),
> > 		ALL_ONES(e), ALL_ONES(f), ALL_ONES(g), ALL_ONES(h),
> > 		ALL_ONES(i), ALL_ONES(j));
> > which then gives 0xffffffff for the first 4 entries.
>=20
> Except I copied the wrong format line :-( It should be:
>  	printf("%x %x %x %x %x %x %lx %lx %llx %llx\n",
>  		ALL_ONES(a), ALL_ONES(b), ALL_ONES(c), ALL_ONES(d),
>  		ALL_ONES(e), ALL_ONES(f), ALL_ONES(g), ALL_ONES(h),
>  		ALL_ONES(i), ALL_ONES(j));

Oh ok, I see the issue now.

So the problem is that this value gets bigger than what the maximal
value for the type passed as argument is supposed to be.

I think the issue is clear now and why a double cast is good.

Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--HnQK338I3UIa/qiP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRp0UbAAoJEADl0hg6qKeOUhYP/2pGCvpbpJ9O/YTwk5s0RLxe
/uGx8ERn3r/jeco419ksdbvralX6DbntjJIWmeS/dhdsNEllMP34ksz+qblHkww2
Mwd56gD1aKpuGCPCbxTwAsGRDvuKmbob0WsRIWqL6htQT4sx4RY/i1boLLYlSLiq
6tciF9PeUDR6Cfh2GSwRfNTwlBSa47HmXarBovzf3JUEp04een7NXaGwhv9F4ftG
EgCTcM6J2GBO8G6VnjttWtnxHKXdKybOgVGmf7KvHm53Y6PNMTW94y+qPq9TKXKm
km/T0ABGUyK3cTbgbKbKzS1VHOPFwEAzUoddPyOCmZ1przgnTQpUIRv5HzzhkxBs
uWC5l0p/KJWUTV1PQwAiQ5n3IU/43ZG+S2hRzRIcw5Uj1pbWcMVpDrssk8i/IG58
nE8zie9wOu1qdZOhjOozTj419kFdHzBvyAqsVkalBtZXSWEuGyBs2JtjN/M4gq7Z
Elh7CtXTa5QwY59YAG/7BBAn2PxVgsFo+u6ncdR7QFBapSv+abvNXdIPGDDX/mdt
PbFBz+F1DTYtyALaYNSmEIHczdhQRMJ5aUpS+p3IMKCBCuZ3SVkqTdvhjlyWrvqi
SHaNoOgVpUvbb5xfzzGExwYveSu3YhPt6eAYhpoqcwNF5FFlpBNgLATgaDGG5pYM
Cpmk08JQPuBQ1LsfzcfG
=0naV
-----END PGP SIGNATURE-----

--HnQK338I3UIa/qiP--
