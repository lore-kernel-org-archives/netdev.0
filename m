From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Mon, 28 Oct 2013 15:00:24 +0100
Message-ID: <201310281500.24159@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <201310281449.58170@pali> <1382968522.17956.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart345760620.OzhjffakOm";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382968522.17956.11.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart345760620.OzhjffakOm
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 28 October 2013 14:55:22 Johannes Berg wrote:
> On Mon, 2013-10-28 at 14:49 +0100, Pali Roh=C3=A1r wrote:
> > On Monday 28 October 2013 14:45:05 Johannes Berg wrote:
> > > On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
> > > > Driver wl1251 generating mac address randomly at startup
> > > > and there is no way to set permanent mac address via
> > > > SET_IEEE80211_PERM_ADDR. This patch export sysfs file
> > > > which can set permanent mac address by userspace helper
> > > > program. Patch is needed for devices which do not store
> > > > mac address in internal wl1251 eeprom.
> > >=20
> > > This doesn't really seem like a good idea since you can
> > > also just use 'ip' or whatever to set the MAC address.
> > >=20
> > > johannes
> >=20
> > AFAIK you cannot set permanent address (show by ethtool -P
> > wlan0) via ip/ifconfig.
>=20
> You probably can't, but that address also doesn't matter at
> all and isn't really used anywhere.
>=20
> johannes

There are some (proprietary) applications which using permanent=20
address for something...

And also more important: some network managing tools using it.=20
NetworkManager resetting current MAC address to permanent one=20
before starting configuring interface.

So this will lead to never use correct MAC address (but random=20
permanent one) assigned for that wl1251 wireless card...

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart345760620.OzhjffakOm
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlJubfgACgkQi/DJPQPkQ1JkVgCePETpdDNGvuSuoZV7u+ya1GhY
dq8Anja0MntOATEspX7Bvjqs640xJ85L
=kxw3
-----END PGP SIGNATURE-----

--nextPart345760620.OzhjffakOm--
