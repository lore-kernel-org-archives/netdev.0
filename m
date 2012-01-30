From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Mon, 30 Jan 2012 14:41:17 +0000
Message-ID: <1327934477.5400.448.camel@deadeye>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	 <1327205171.8004.96.camel@deadeye>
	 <SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	 <20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
	 <1327811546.5400.291.camel@deadeye>
	 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
	 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327932311.5400.429.camel@deadeye>
	 <1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-es1ZdJ5QjOgqSjOkOV9v"
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	"Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51220 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753298Ab2A3Old (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:41:33 -0500
In-Reply-To: <1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-es1ZdJ5QjOgqSjOkOV9v
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-01-30 at 15:28 +0100, Eric Dumazet wrote:
> Le lundi 30 janvier 2012 =C3=A0 14:05 +0000, Ben Hutchings a =C3=A9crit :
>=20
> > Yes, I spotted that.  But no descriptors are pushed to the hardware
> > here; that's done in the driver's TX tasklet.  Although... maybe that
> > can run immediately when scheduled from here?  I've never had to deal
> > with tasklets so I really don't know their semantics.
>=20
> Thats probable on SMP ...

The bug report is for a UP system running a kernel built with
SMP-alternatives.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-es1ZdJ5QjOgqSjOkOV9v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATyasDue/yOyVhhEJAQpO/xAAqq8SEN2VWfHZmmeRf7SHXiTlerbJq9c4
NJQh/FKGGVPkPnw/Xk6WvedcC2xbS1vaLThRU5OTic4O8127qIMbY/v9iYjrABJ2
7gYu7itmeCfVwS7hSUDWGIVl3eC9imBDqkIfxwie5FuCLV22VjwWuHdQUnlmuLz/
MBdQoputd1FCcNcpH3PlNHtLjD+EWMq9CPO4I3gU8w+Vgs4qbpOEOL17AXnqOZat
cZRjN1I1SOY9q/+F1TNGV4grW0Mg5hMBau/J+GXIEskT2qZlVD6kvILLUwAnVGDD
uACYoAeWpQnmxCrR/s6iY8mbxVhS25VszcaGkzx3mgi5ZJqGQFT0rqlQ6Ov+fO1d
vyA+wQv7s7bPHOQe+4eqkwxpewkw7OhxMZka1r05WjsbneqMnnU7Vl6dAD8wTYSh
ntn3ab6oRYbLmOfuxrsQs5Mi3IiuNkjj1cB0iLk9lI5fdNaLHLyQ7LoI9YG44+9Z
frbYM5wrlX7Iqw2B4B6z8CFN+tTnZK75/ATv+PrQNpkiUuJCRJ9mtHboSbp3dzSw
Gi6CTFmQxHuRnuaOG5x6hERe5h1K4kd+axtFnLNPjWxHrQsGgBLkRLmunDmbrnhe
UEgC+J02efTAIGcpzRgcRXPuH3GojQvt5sOFdkepiXJV/eCHBckuAgnWRkxtcbww
cxe5gsO3Qk8=
=EXAf
-----END PGP SIGNATURE-----

--=-es1ZdJ5QjOgqSjOkOV9v--
