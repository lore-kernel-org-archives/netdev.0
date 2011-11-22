From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: drivers/net: Kconfig & Makefile cleanup
Date: Tue, 22 Nov 2011 06:51:02 +0000
Message-ID: <1321944662.2839.222.camel@deadeye>
References: <1321944512.2839.219.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xgh/mmn4iWPPcfI3QiV3"
Cc: netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54197 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755240Ab1KVGvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 01:51:11 -0500
In-Reply-To: <1321944512.2839.219.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xgh/mmn4iWPPcfI3QiV3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

You wrote that (some time ago now):
> As a side cleanup, found that the arcnet, token ring, and PHY
> Kconfig options were a tri-state option and should have been
> a bool option.

How did you decide that?  This seems to be correct for TR, but ARCNET
and PHYLIB each select some support code that can be built as a module
(and which has been, in Debian).

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-xgh/mmn4iWPPcfI3QiV3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATstGVue/yOyVhhEJAQrguxAAiWmU5sWYJ2ytzjmUA471L5AEz0UQRaQy
ZkwFuqpcA38CFPoJ/L1FfXQma3cpw7ic+Ib70b6rBl1lCKWw3oDZYdPcRv+CHe7A
mTXQ2Q7TlrcQRYyXE6NQsD6cbnC2zr6pPylTGlTP25pST4PqN885vJZTVaM5olXG
VUoLYlomktQLffJumCGZHF2SzdwPRNxqJ0CuLIJvWQ3CSLgQA45E22cQtuwTm75S
LwwBmdMjBlPJshu8tooyouF5J6Q8B7aVNXd3ziDA0Xyfr/dn9MRuFNgV07rTXr+Q
s87eeKr3PHhFW9HCfkZJeRUztA8Qixv5nyicDYJHIAnIWvr+yQFRVQK3J1w1QcDQ
N6EtJxRryaxydoRt+gO/cvEL70HmwsVqv4LqKRMwsIILdSJ5XJOuxXPCCT8PQ50y
l+gAOLuTQbYp5RAmAjX8w8oplhQGTKvJobvmOwt1CKKeSb55tA1IVrAQYTALdlK9
BylUm9bQu2m28gfBgx9KV5bn6qYZ3ubeaBPc3p3ys3WjgL8R8L/n7oSdbNIWgLMs
g0B6IH8JpNDv6Vw/PE8rmfOSFhGIkydhgApekkgx7d5sMD/NEx//2hrrAsyBsJ0x
qbtrPAt/diC8vumhRszVZnI+pHsN8jsgYt/KZDqXGohb4t6iKbkxgiJ1V3ij0xGX
HkYmBFD5ylo=
=Bdfh
-----END PGP SIGNATURE-----

--=-xgh/mmn4iWPPcfI3QiV3--
