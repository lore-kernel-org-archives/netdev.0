From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/8] farsync: Fix confusion about DMA address and buffer
 offset types
Date: Mon, 28 Oct 2013 04:51:25 +0000
Message-ID: <1382935885.3524.38.camel@deadeye.wl.decadent.org.uk>
References: <1382910437.2994.43.camel@deadeye.wl.decadent.org.uk>
	 <1382910704.2994.46.camel@deadeye.wl.decadent.org.uk>
	 <20131028.002627.2095063739326406659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VUp4e/h2ncOFZyylaDOW"
Cc: kevin.curtis@farsite.co.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131028.002627.2095063739326406659.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VUp4e/h2ncOFZyylaDOW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-10-28 at 00:26 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 27 Oct 2013 21:51:44 +0000
>=20
> > -     dbg(DBG_TX, "In fst_tx_dma %p %p %d\n", skb, mem, len);
> > +     dbg(DBG_TX, "In fst_tx_dma %x %x %d\n", (u32)skb, mem, len);
>=20
> Please use %p for the skb pointer instead of casting it (which btw
> will introduce a warning on 64-bit).

skb is the DMA address of the data in the sk_buff.  Yes, this is really
unusual naming.

Ben.

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-VUp4e/h2ncOFZyylaDOW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUm3tTee/yOyVhhEJAQpGqxAAvGJN9eR2tMFkPbkzAq2/tUO/1zS1nLvj
J+Ufmk6ixxj02xQxXfCpVCTHC5/nJuiGEOZoAlVFOUwpe501M0XtIyMR6/VyCevm
RCe/j/k0DLpHX/QDJuYoWjpYw/8IkrRs7X1KH2cn0pMQ394gWCWwGL/NnO8T2jn4
juxZ2wJ9Oc6aUBCSLTQNFIu9fQSMUg08kxHlutEpHhmJ2yl4opaPhI1GFtAABEUX
ydOqC0y39PtemaJu5InD+mFQAy7wflus7P0iwzCpaXckb/Qb55onyaTp3bn4Zdv/
OGlTOgmexZ64cjTZvFEs32HYygbBXkP3JGoMeprVQvNZIqQGGRiaEI9juEN46Ahd
nGgHSKgkQf3MKnwkIBJ9mJkQ0p2LS5G50y01V4wucYbBrm4a62zLSZLiaeYsi/rI
lwuoLVkvFyCPxSprkaiZZENXYVCRrjJvGQuOclwGJooYG93rFBqRJawVWBK7C4wg
7aNyL5D0yG6QAKYT7JbmkgkdhGl60xz3yxk+Yv339mMqWWX75ux7IziTCxvW75aP
jfzV0Emi0Z/a5ejDKR7Umhn9SJESdS8PBctrZLiGiFLSP8ZFfXoSp3vHPE7Csj48
1O4ETUKVS5JqhhfFBWZVaymaMXSyDLn//VMgEzjI/rp7XT2uAMHSm1aFsbat7d2L
nGHTI2EeARU=
=gE32
-----END PGP SIGNATURE-----

--=-VUp4e/h2ncOFZyylaDOW--
