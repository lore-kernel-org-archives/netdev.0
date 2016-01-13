From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Wed, 13 Jan 2016 23:39:49 +0100
Message-ID: <201601132339.50004@pali>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com> <5696D08F.9030906@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9379298.SYUCXtDZX4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Gnedt <david.gnedt@davizone.at>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5696D08F.9030906@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart9379298.SYUCXtDZX4
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 13 January 2016 23:32:47 Arend van Spriel wrote:
> On 12/26/2015 12:45 PM, Pali Roh=C3=A1r wrote:
> > Port the bt_coex_mode sysfs interface from wl1251 driver version
> > included in the Maemo Fremantle kernel to allow bt-coexistence
> > mode configuration. This enables userspace applications to set one
> > of the modes WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and
> > WL1251_BT_COEX_MONOAUDIO. The default mode is WL1251_BT_COEX_OFF.
> > It should be noted that this driver always enabled bt-coexistence
> > before and enabled bt-coexistence directly affects the receiving
> > performance, rendering it unusable in some low-signal situations.
> > Especially monitor mode is affected very badly with bt-coexistence
> > enabled.
>=20
> So what user-space process will be using this interface.

On Maemo daemon wlancond use this interface. It use information from=20
bluez daemon to decide if btcoex is needed to enable or not (and also=20
which mode).

> Did you consider adding debugfs interface?

Other drivers uses sysfs, so I proposed also sysfs interface.

> In case of monitor mode you could
> consider disabling bt-coex from within the driver itself.

I'm not sure if you want to do it always in this case...

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart9379298.SYUCXtDZX4
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlaW0jUACgkQi/DJPQPkQ1JgcACgqv0VNU+3jY2ExMnTgpXtU8Xi
4XMAnjtGGOwb2/DgggXPGrvH456GdPR3
=wEtO
-----END PGP SIGNATURE-----

--nextPart9379298.SYUCXtDZX4--
