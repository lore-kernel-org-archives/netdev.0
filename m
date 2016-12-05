From: Pavel Machek <pavel@ucw.cz>
Subject: Re: e1000e on Thinkpad x60: gigabit not available due to "SmartSpeed"
Date: Mon, 5 Dec 2016 11:44:47 +0100
Message-ID: <20161205104447.GA7536@amd>
References: <20160901201408.GA5061@amd>
 <1472767093.3889.4.camel@gmail.com>
 <20160902165735.GJ14311@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
Cc: Greg <gvrose8192@gmail.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:40959 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbcLEKot (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 05:44:49 -0500
Content-Disposition: inline
In-Reply-To: <20160902165735.GJ14311@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2016-09-02 12:57:35, Lennart Sorensen wrote:
> On Thu, Sep 01, 2016 at 02:58:13PM -0700, Greg wrote:
> > On Thu, 2016-09-01 at 22:14 +0200, Pavel Machek wrote:
> > > Hi!
> > >=20
> > > I have trouble getting 1000mbit out of my ethernet card.
> > >=20
> > > I tried direct connection between two PCs with different cables, and
> > > no luck.
> > >=20
> > > Today I tried connection to 1000mbit switch, and no luck, either. (Two
> > > cables, one was cat6, both short).
> > >=20
> > > My computer sees 1000mbit being advertised by the other side, but does
> > > not advertise 1000mbit, "Link Speed was downgraded by SmartSpeed".
> >=20
> > Check your cables?
> >=20
> > https://vmxp.wordpress.com/2015/01/06/1gbe-intel-nic-throttled-to-100mb=
it-by-smartspeed/
>=20
> Of course if it isn't the cable, then it could even be a broken pin in
> the port.  As far as I can tell, anything that causes one of the 3rd
> or 4th pairs of wires to not work will degrade to 100Mbit on just the
> first 2 pairs of wires and give that message.  Some badly implemented
> switches can also cause it of course.

Ok, so it seems like broken pin in the port. I realized I had docking
station available for the machine, and when connecting using that
connector (not internal notebook one), I get gigabit speed.

Thanks and best regards,
								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhFRR8ACgkQMOfwapXb+vIW9gCdEjEOshjhJp8NjZcyPpBQyMif
1UoAn1IC5jEs9/2OuFYVSz2Nz6GA3NyA
=7Rds
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--
