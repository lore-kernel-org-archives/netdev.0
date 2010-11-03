From: md@Linux.IT (Marco d'Itri)
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to
	start_udev
Date: Wed, 3 Nov 2010 19:32:47 +0100
Message-ID: <20101103183247.GA28139@bongo.bofh.it>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com> <20101103180500.GA7441@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Cc: Narendra_K@Dell.com, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101103180500.GA7441@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov 03, Greg KH <greg@kroah.com> wrote:

> Why not do this in some other configuration file?  Don't rely on udev
> being started with a different option, that is only ripe for abuse by
> everyone else who wants their pet-project to get into the udev
> environment.
Agreed. What about instructing users/installers to add something like
this in /etc/udev/rules.d/00-something.rules?

KERNEL=3D=3D"eth*", ENV{UDEVLOM}=3D"1"

(Maybe with a more descriptive name than "UDEVLOM".)

--=20
ciao,
Marco

--DocE+STaALJfprDB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkzRqs8ACgkQFGfw2OHuP7EYEACZAeDc/phuXkT89y+bGtsYROYN
Pw0An1Lti6pAyXjt/pjIj8L9h7V5hXTC
=Keaz
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--
