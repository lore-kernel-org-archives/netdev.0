From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 14 Jun 2006 17:08:28 +0200
Message-ID: <1150297708.26187.125.camel@localhost.localdomain>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <44901CC1.60403@cfl.rr.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4ffjErETNjtEUGjcGhsY"
Cc: netdev@vger.kernel.org, russell-tcatm@stuart.id.au, hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex001a.cxnet.dk ([195.135.216.13]:54788 "EHLO
	comxexch01.comx.local") by vger.kernel.org with ESMTP
	id S964995AbWFNPI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 11:08:29 -0400
To: Phillip Susi <psusi@cfl.rr.com>
In-Reply-To: <44901CC1.60403@cfl.rr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-4ffjErETNjtEUGjcGhsY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-06-14 at 10:27 -0400, Phillip Susi wrote:
> Jesper Dangaard Brouer wrote:
> > The Linux traffic's control engine inaccurately calculates
> > transmission times for packets sent over ADSL links.  For
> > some packet sizes the error rises to over 50%.  This occurs
> > because ADSL uses ATM as its link layer transport, and ATM
> > transmits packets in fixed sized 53 byte cells.
> >=20
>=20
> I could have sworn that DSL uses its own framing protocol that is=20
> similar to the frame/superframe structure of HDSL ( T1 ) lines and over=20
> that you can run ATM or ethernet.  Or is it typically ethernet -> ATM ->=20
> HDSL?

Nope, not according to the ADSL standards G.992.1 and G.992.2.

> In any case, why does the kernel care about the exact time that the IP=20
> packet has been received and reassembled on the headend?

I think you have misunderstood what the rate table does...
(There is an explaination in the thesis page 57 section 6.1.2)
http://www.adsl-optimizer.dk/thesis/

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk


--=-4ffjErETNjtEUGjcGhsY
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEkCZswuVH+NB3fZkRAo+kAJ43vH6ref8tpO9MshfbuNvjQm4krACgifVG
i8MDQxfwLjwJ8KQ2DN9w6B4=
=Q6jF
-----END PGP SIGNATURE-----

--=-4ffjErETNjtEUGjcGhsY--

