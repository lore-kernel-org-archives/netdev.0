From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Mon, 28 Oct 2013 14:49:57 +0100
Message-ID: <201310281449.58170@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <1382819655-30430-17-git-send-email-pali.rohar@gmail.com> <1382967905.17956.8.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1996909.omHDmAVbmR";
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
In-Reply-To: <1382967905.17956.8.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1996909.omHDmAVbmR
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 28 October 2013 14:45:05 Johannes Berg wrote:
> On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
> > Driver wl1251 generating mac address randomly at startup and
> > there is no way to set permanent mac address via
> > SET_IEEE80211_PERM_ADDR. This patch export sysfs file which
> > can set permanent mac address by userspace helper program.
> > Patch is needed for devices which do not store mac address
> > in internal wl1251 eeprom.
>=20
> This doesn't really seem like a good idea since you can also
> just use 'ip' or whatever to set the MAC address.
>=20
> johannes

AFAIK you cannot set permanent address (show by ethtool -P wlan0)=20
via ip/ifconfig.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1996909.omHDmAVbmR
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlJua4YACgkQi/DJPQPkQ1JbmACgngFKM192sHlcxzpWCh9/YeQD
rM8An1PkzO/OblkbtvxanYq8noy7WwGN
=ZZHU
-----END PGP SIGNATURE-----

--nextPart1996909.omHDmAVbmR--
