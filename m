From: md@Linux.IT (Marco d'Itri)
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 14:51:00 +0200
Message-ID: <20080414125100.GA13564@bongo.bofh.it>
References: <ftdb3v$tls$1@ger.gmane.org> <20080407143805.GA9492@bongo.bofh.it> <1208167737.31695.32.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: Harald Hoyer <harald@redhat.com>, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1208167737.31695.32.camel@pmac.infradead.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Apr 14, David Woodhouse <dwmw2@infradead.org> wrote:

> Actually it's a generic problem. It also occurs on OLPC, where the
> libertas wireless device presents two interfaces with the same MAC
And on some Sun systems as well.

> > Unconditionally adding a KERNEL key means that persistent names will
> > break if a driver changes the base name (e.g. wlan* -> eth*).
> Drivers shouldn't do that. It'll change the name of the device and may
But they do...

> We could modify the libertas and gelic (and any other affected) drivers
> to provide a dev_id, make sure it's exported in sysfs, and then use that
> in the udev rules. Would that make you happy?
Yes, I like not fixing just the symptoms. :-)

> It has implications w.r.t. the autoconfigured IPv6 addresses of those
> devices,
How so?

> > This workaround should be confined to the PS3 install media, there is
> > no reason to add it to general-purpose distributions.
> Our general-purpose distribution installs and runs on PS3. :)
So if PS3 needs special hacks they should be special-cased to only by
used on PS3 hardware.

--=20
ciao,
Marco

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIA1M0FGfw2OHuP7ERAp+SAJ9mMgHuRlCg09jj7Vi9EmSiGV16TACbBRhG
Artj7C2zTFLsKfcU1QT1O2k=
=xie9
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
