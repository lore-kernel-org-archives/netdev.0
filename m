From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/12][pull request] Intel Wired LAN Driver Updates
Date: Fri, 07 Mar 2014 13:37:28 -0800
Message-ID: <1394228248.2101.6.camel@jtkirshe-mobl.jf.intel.com>
References: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20140307.161933.284876266168174096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PQafUIC6PHE0xWG5L9sG"
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62803 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbaCGViO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 16:38:14 -0500
In-Reply-To: <20140307.161933.284876266168174096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PQafUIC6PHE0xWG5L9sG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-07 at 16:19 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu,  6 Mar 2014 18:59:12 -0800
>=20
> > This series contains updates to i40e and i40evf.
> >=20
> > Most notable are:
> > Joseph completes the implementation of the ethtool ntuple rule
> > management interface by adding the get, update and delete interface
> > reset.
> >=20
> > Akeem provides a fix to prevent a possible overflow due to multiplicati=
on
> > of number and size by using kzalloc, so use kcalloc.
> >=20
> > Jesse provides an implementation for skb_set_hash() and adds the L4 typ=
e
> > return when we know it is an L4 hash.  He also adds a counter to
> > statistics for Tx timeouts to help users.  Lastly he provides a change
> > to stay away from the cache line where the done bit may be getting
> > written back for the transmit ring since the hardware may be writing th=
e
> > whole cache line for a partial update.
> >=20
> > Shannon cleans up code comments.
> >=20
> > Anjali removes a firmware workaround for newer firmware since the numbe=
r
> > of MSIx vectors are being reported correctly.
> >=20
> > v2:
> >  -  dropped patch 01 of the series based on feedback from the author
> >     Joe Perches and Shannon Nelson.
>=20
> Pulled, thanks Jeff.
>=20
> And I'd like to make a broad long-term comment, actually about vf
> drivers in general....
>=20
> There is so much common code between pf and vf drivers, as a quick
> example even in this patch set the skb_set_hash() stuff is pretty
> much the same for i40e and i40evf.
>=20
> I realize there are subtle differences between vf and pf, however
> you can't say that there isn't a metric ton of common code.
>=20
> Please consider seriously making a common layer for these kinds of
> driver pairs.  I absolutely do not care, as an initial step, if the
> common code just gets linked directly into the final module object
> for the two drivers.  Although eventually it would be nice if the
> common layer driver was a shared module object on it's own that is
> simply depended upon by the pf and vf drivers.
>=20
> Thanks.

Thanks Dave!  I will work with i40e developers to get a solution put
together for the shared code.

--=-PQafUIC6PHE0xWG5L9sG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTGjwYAAoJEOVv75VaS+3ORBYP/2+eRJWIRLq3H7srlVBh1RLa
chORGGV7nG5LliqKlZjsVgVbSXBGtn5SLYilYxpzpztGsky3foxgrVqECfQYv8aa
k09DgwOyQqIG6DY4mEEL52DBdbAeWoUXJ7DY49uFKMCfotQoDIW3g1hX+WTgbK+E
5t50/+ohkDpAlMZUKyivnLGYLvHgdVKY1cfSXDZsu9+3edvLJBddZ4X/VaDErkOQ
pAKftdcCJwqxI4KvlncwxbafhrTVe9xE35ui5Si++29yFyIgJUOSpQZuuKDsTb/3
XJuT1HbXMQc9sYlsUO7P5DywNOxMKiqNEmRn/NjZ5fCHbS0wwhtYTto38qRCmcyb
94QfbnIzQPmBZnsR7U3RXkHzU51VCUEcO0rE0hTgDZDbX5B4/qE31yEkP5C0f+BI
gcrhqnenOaJl0ka7TOnB1IMQI0RPJXbpjqLpT6Nhr/bPWoW91smuUphDW0jSyDy4
XWSFxEjbj53obpQ4Fp3GstarMaYZaIDUU1u3iksA8DIkUroZlRiIZtXVSVj6cRiL
MoNtKf+EaVUMsg7eEw3dcwbqlCKqwqQMPK4q6XgjDbWvy+MLYn2B2PYfXSGm5KuJ
LZUuhrPqBCmCmGUC7J78/6ZRXqH/TPr1kSHfg53/Yao0A+uldGJc7gCPbckyz1kL
SZdVeDf9jaESZg71RS8z
=c5O+
-----END PGP SIGNATURE-----

--=-PQafUIC6PHE0xWG5L9sG--
