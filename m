From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 02:45:28 +0100
Message-ID: <20060728014528.GB29313@innerghost.net>
References: <44C8B0B8.2010408@miyazawa.org> <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kVXhAStRUZ/+rrGn"
Cc: herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:51861 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1751783AbWG1Bpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 21:45:30 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060727.183415.104032934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--kVXhAStRUZ/+rrGn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David,

> If we process these in sequence in software interrupt, everything
> is fine.  Processing of "A" will add the address, and the test
> ping packet "B" will respond properly.
>=20
> If you defer "A", everything breaks and the test packet "B" will
> get processed first and not work.

   Is it reasonable to consider that control packet processing needs to
 be serialized with data packet processing? In this particular case, is
 it not the tests that are broken if not giving enough time to the host
 to configure the address? The standards do not specify implementation
 details so no specific processing model should be assumed, and what you
 describe sounds a bit like an ideal model.

> As a secondary reason not to even consider this, it's in the kernel
> already and therefore it is totally impractical to try and remove it.

   I'm not sure if it was clear from my original e-mail, but i'm not
 suggesting removing any of the functionality from the kernel -- it is
 clear the current implementation is useful in out of the box
 deployments. Instead, i would like to know what was the possibility of
 having a bit of new functionality that would allow this specific
 methods to be outsourced to an user-space control application. And by
 specific methods i'm refering to NDISC message processing, "neighbor
 entry needs refreshing" events, etc.

   Hugo


--kVXhAStRUZ/+rrGn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEyWw47asb/itUNKwRAgK8AJ9J0MBYhXRUDf0b9JA5RHIQVof2agCg1wU8
hXFMp65BBOY4cr/uH/jtBGQ=
=uVdV
-----END PGP SIGNATURE-----

--kVXhAStRUZ/+rrGn--
