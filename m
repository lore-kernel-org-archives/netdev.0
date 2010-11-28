From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] econet: Move to staging; remove from defconfig
Date: Sun, 28 Nov 2010 15:11:16 +0000
Message-ID: <1290957076.3292.277.camel@localhost>
References: <20101128002135.GA4562@suse.de>
	 <20101127.172644.226781076.davem@davemloft.net>
	 <1290909215.3292.230.camel@localhost>
	 <20101127.223845.189711153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-brugXa3N3N/8GF5jyQud"
Cc: gregkh@suse.de, netdev@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-arm-kernel@lists.infradead.org, debian-kernel@lists.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
In-Reply-To: <20101127.223845.189711153.davem@davemloft.net>
Resent-Message-ID: <MIzdnbqcBsO.A.RZ.uEn8MB@liszt>
List-URL: <http://lists.debian.org/debian-kernel/>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org


--=-brugXa3N3N/8GF5jyQud
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-11-27 at 22:38 -0800, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 28 Nov 2010 01:53:35 +0000
>=20
> > On Sat, 2010-11-27 at 17:26 -0800, David Miller wrote:
> >> From: Greg KH <gregkh@suse.de>
> >> Date: Sat, 27 Nov 2010 16:21:35 -0800
> >>=20
> >> > And I need an ack from the networking maintainer to be able to accep=
t
> >> > this also.
> >>=20
> >> I'm not applying this, nor do I want anyone else to.
> >>=20
> >> If people think this protocol is not maintained adequately
> >> right now, wait until you push it into staging.
> >>=20
> >> Furthermore, once Phil Blundell was made aware of security
> >> holes in econet he fixed them within a few days.  Which is
> >> much better than I can say for some of the other protocols
> >> and filesystems in the tree.
> >=20
> > Those bugs were present for years and would have been obvious to anyone
> > who cared to read the code.  While I very much appreciate Phil's quick
> > response, I don't think this reactive maintenance is enough.
>=20
> These same arguments could for be made for RDS.  Look at all the
> hellacious awful obvious crap we've discovered in that code recently.
> A simple read would have caught those too, and I don't see it's
> maintainer doing such things.

Indeed, hence the change I made for the upcoming Debian release was:

  * af_802154,decnet,econet,rds,x25: Disable auto-loading as mitigation
    against local exploits.  These protocol modules are not widely used
    and can be explicitly loaded or aliased on systems where they are
    wanted.

(While decnet may be in better shape than the others, auto-loading is
unnecessary for us as the userland support package explicitly loads
it..)

> So, you're very much still not convincing Ben, but feel free to keep
> trying.

I'm not going to try any more.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-brugXa3N3N/8GF5jyQud
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATPJxC+e/yOyVhhEJAQJcDRAAtC3UrOJ6bloYqGmcPgvZJWoWOrzAkjjl
1v6GRSXjkMeK70ftLQ7tN6Gx273VJcdb/MwiXWdm1tafA/fimmHQtf4krchJhQgo
88snfLT6STEDVWftfEyXln9LizhdG9BUHuNDX0Gu8/tYyor0U7gMCABxclt2ZQCl
S5e/M5/bMd2+ne1OaEno2y3UoYs5TGVP0LCLP/QA9pk7socJGux4PpA82czEQGyo
582ve5vuUJ5PcI0ZJTPgDFC9REvliUcIO4FRk1XbBdcu4M0ABEJ55WA1ptkBsRBd
tn6psg75YwnPprfCwAJzZKKAwHIjz98QHcN2NKg3HxWLl/Kd6li+v3pHV/85p7MD
gyb5BAc2DAM0NcGhLgEEdQ4Fhj+GMUqQoZaqqK61C1KMJv+9HBcKw1WU0I2XLdWs
AzdgvlRpJGSPJfKvXOyMNwpzmIaLAwrsZ6H9ZdA9+e3Fu1BWpMNDXEctxI1X3cyL
nNi6KNF/18EbastN5x6eHxgag1No+GCCQK5nB2kXk79KmjWlRmbavZtnitjajNQd
kThhsrDkzlSg2/xPpYQQGMv0ia7j5KsvdqZOvGMJIw1NjcFhCFK503zLeauprTED
on+MzSFS0Vrn85usislc4o9dmC1Gh17zrvulWWzA9LxrIiYoGAxjmxfzVYeMoUOC
ZUVyLWz1mTM=
=jPK1
-----END PGP SIGNATURE-----

--=-brugXa3N3N/8GF5jyQud--
