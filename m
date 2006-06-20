From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 09:33:25 +0200
Message-ID: <1150788805.3480.31.camel@localhost.localdomain>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <20060620053536.GA10311@tuatara.stupidest.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3gsW3VxIo49i4V0m7YvI"
Cc: netdev <netdev@vger.kernel.org>, russell-tcatm@stuart.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex001a.cxnet.dk ([195.135.216.13]:11121 "EHLO
	comxexch01.comx.local") by vger.kernel.org with ESMTP
	id S965127AbWFTHd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 03:33:27 -0400
To: Chris Wedgwood <cw@f00f.org>
In-Reply-To: <20060620053536.GA10311@tuatara.stupidest.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3gsW3VxIo49i4V0m7YvI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Mon, 2006-06-19 at 22:35 -0700, Chris Wedgwood wrote:
> On Wed, Jun 14, 2006 at 11:40:04AM +0200, Jesper Dangaard Brouer wrote:
>=20
> > The Linux traffic's control engine inaccurately calculates
> > transmission times for packets sent over ADSL links.  For some
> > packet sizes the error rises to over 50%.  This occurs because ADSL
> > uses ATM as its link layer transport, and ATM transmits packets in
> > fixed sized 53 byte cells.
>=20
> What if AAL5 is used?  The cell-alignment math is going to be wrong
> there surely?

Actually it _is_ AAL5 which is accounted for.

See Chapter 5 "ADSL link layer overhead" (page 48-54).
http://www.adsl-optimizer.dk/thesis/main_final_hyper.pdf

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk


--=-3gsW3VxIo49i4V0m7YvI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBEl6TFwuVH+NB3fZkRAvrlAJ9Is5CDyMSjd/bcC77e7UNPG1vEhACfdIDc
rclEWoWa2fiePYrPVONrOIk=
=nXhD
-----END PGP SIGNATURE-----

--=-3gsW3VxIo49i4V0m7YvI--

