From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: net: alignment problem in icmp code
Date: Sun, 21 Oct 2007 23:21:13 +0200
Message-ID: <20071021232113.52ce1be7@poseidon.drzeus.cx>
References: <20071020233540.43d2f103@poseidon.drzeus.cx>
	<20071020.221257.78359286.davem@davemloft.net>
	<20071021113405.37fa0bc5@poseidon.drzeus.cx>
	<20071021.124814.50617600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-8504-1193001648-0001-2"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:45054 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbXJUVVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2007 17:21:25 -0400
In-Reply-To: <20071021.124814.50617600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-8504-1193001648-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2007 12:48:14 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

>=20
> You are missing a crucial point.
>=20
> The compiler may emit the same exact loads and stores when it inlines
> memcpy() if it "knows" the objects are aligned properly.  And it very
> much will do this.
>=20

Not sure that would be valid. memcpy() is defined as having void* arguments=
, and the compiler cannot just ignore that if it chooses to inline it.

Still, just give it the char* from the skb and it cannot make any assumptio=
n on alignment.

Rgds
Pierre

--=_hera.drzeus.cx-8504-1193001648-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHG8LJ7b8eESbyJLgRAjPPAKDm7TvL4sIIwaI1+7wC63O/gLig3wCcDDuZ
1ayRvjIiQjy0mz+cQI+RxJY=
=rVrh
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-8504-1193001648-0001-2--
