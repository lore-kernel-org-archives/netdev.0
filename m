From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Tue, 06 Mar 2007 01:55:46 +0100
Message-ID: <1173142546.15891.63.camel@johannes.berg>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
	<20070305015031.GF3441@stusta.de>  <20070305033533.GA28319@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1304735898=="
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, Pavel Machek <pavel@ucw.cz>,
   Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
   Marcel Holtmann <marcel@holtmann.org>, linux-pm@lists.osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Adrian Bunk <bunk@stusta.de>, bluez-devel@lists.sourceforge.net,
   maxk@qualcomm.com, Matt Mackall <mpm@selenic.com>, Mark Lord <lkml@rtr.ca>,
   Andrew Morton <akpm@linux-foundation.org>,
   Sid Boyce <g3vbv@blueyonder.co.uk>,
   Linus Torvalds <torvalds@linux-foundation.org>,
   Albert Hopkins <kernel@marduk.letterboxes.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070305033533.GA28319@kroah.com>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org


--===============1304735898==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-i3jBLRY+r3mxA0BLoyxz"


--=-i3jBLRY+r3mxA0BLoyxz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-03-04 at 19:35 -0800, Greg KH wrote:

> > Subject    : wireless breakage (ipw2200, iwconfig, NetworkManager)
> > References : http://lkml.org/lkml/2007/3/4/135
> > Submitter  : Matt Mackall <mpm@selenic.com>
> > Caused-By  : Greg Kroah-Hartman <gregkh@suse.de> (?)
> >              commit 43cb76d91ee85f579a69d42bc8efc08bac560278 (?)
> > Handled-By : Johannes Berg <johannes@sipsolutions.net>
> > Status     : unknown
>=20
> I really think this is a CONFIG_SYSFS_DEPRECATED issue (not being set),
> but want to get Matt confirm either way before saying this is a real
> issue or not.

I just tested on my quad powermac that also runs a stock Debian/unstable
and changing that option makes all the difference. Nevermind that it
defaults to yes and one needs to turn it off explicitly...

johannes

--=-i3jBLRY+r3mxA0BLoyxz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF7LwS/ETPhpq3jKURAuGuAJ90d8Ucs+DvKGONqv3pqz5OhbORZACgqE1G
9nOJkgdgY15qW65IIDjPV60=
=8EIz
-----END PGP SIGNATURE-----

--=-i3jBLRY+r3mxA0BLoyxz--


--===============1304735898==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============1304735898==--
