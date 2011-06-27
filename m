From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Jun 2011 15:29:27 +1000
Message-ID: <20110627152927.943c34dc.sfr@canb.auug.org.au>
References: <20110623152920.31b28b00.sfr@canb.auug.org.au>
	<BANLkTin+iCahNVJGKc-_26pb9zEERTc8_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__27_Jun_2011_15_29_27_+1000_UkAps0kps8eKCbep"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:45632 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756522Ab1F0F3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 01:29:36 -0400
In-Reply-To: <BANLkTin+iCahNVJGKc-_26pb9zEERTc8_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__27_Jun_2011_15_29_27_+1000_UkAps0kps8eKCbep
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Alexey,

On Thu, 23 Jun 2011 16:04:13 +0300 Alexey Dobriyan <adobriyan@gmail.com> wr=
ote:
>
> On Thu, Jun 23, 2011 at 8:29 AM, Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
> > After merging the final tree, today's linux-next build (powerpc
> > allyesconfig) failed like this:
>=20
> I build on all powerpc defconfigs, somehow this driver is not pinned
> by any of them :^)

Well, yes, but an allmodconfig or allyesconfig build will get the error.

>=20
> > drivers/net/ll_temac_main.c:209:4: error: implicit declaration of funct=
ion 'dma_unmap_single'
>=20

Is there a fix?
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__27_Jun_2011_15_29_27_+1000_UkAps0kps8eKCbep
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOCBU3AAoJEDMEi1NhKgbs4D0H/j9A38Xj/HL4y6VR6t9KWfoT
2igqbWDKPBUbWqeNBODUU3afgm3aW9rP7qIXsKXqTAIj9iIRBQD9qjOE13KXls/t
4FFwvjLIlPpniSGSBLj4UPJoahD+BXrgdhUwQab4Cco2Q+t5gsa2BdjZP84GDIs5
iwurrrl50jqDI+wwkN0Nd5IsXfbnU/G8CPuLkxKhiE0pHuyPhGd/lx8ufkoOMMn+
VZ9R5FyqNmKcwaHRwhQObqtuNtoLLkmQNWNS3X6U+Gw76aI/j3OU6RhiF/fRKVNT
eJWcSWFV4QOOjrC6DELXa1R2auWyVLedE8wHbG5p4zwLGQF0od9fRNYh6INc50I=
=9sja
-----END PGP SIGNATURE-----

--Signature=_Mon__27_Jun_2011_15_29_27_+1000_UkAps0kps8eKCbep--
