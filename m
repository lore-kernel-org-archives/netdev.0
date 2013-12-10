From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2 02/16] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Tue, 10 Dec 2013 17:09:38 +0100
Message-ID: <201312101709.38566@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <1386494714-21070-3-git-send-email-pali.rohar@gmail.com> <87y53spv2p.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1900256.WvqENPmUIs";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>
To: Kalle Valo <kvalo@adurom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y53spv2p.fsf@purkki.adurom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1900256.WvqENPmUIs
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 10 December 2013 16:46:54 Kalle Valo wrote:
> Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
> > From: David Gnedt <david.gnedt@davizone.at>
> >=20
> > Port the bt_coex_mode sysfs interface from wl1251 driver
> > version included in the Maemo Fremantle kernel to allow
> > bt-coexistence mode configuration. This enables userspace
> > applications to set one of the modes WL1251_BT_COEX_OFF,
> > WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONOAUDIO. The
> > default mode is WL1251_BT_COEX_OFF.
> > It should be noted that this driver always enabled
> > bt-coexistence before and enabled bt-coexistence directly
> > affects the receiving performance, rendering it unusable in
> > some low-signal situations. Especially monitor mode is
> > affected very badly with bt-coexistence enabled.
> >=20
> > Signed-off-by: David Gnedt <david.gnedt@davizone.at>
> > Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
>=20
> I think this is also what I wrote a long time. And also this
> sysfs hack should not go to upstream.
>=20
> Over the years there has been some talk about solving the BT
> coex properly, but I haven't seen any patches. I guess the
> proper solution would be that BT subsystem in kernel would
> notify wireless drivers about BT use?

See other drivers in upstream, they doing something similar...

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1900256.WvqENPmUIs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlKnPMIACgkQi/DJPQPkQ1IGggCgzNsUtLFGcAD+yCko8VRuygN3
SB0An3DFjuGsXApnVSreed7qES4Dphmd
=/quV
-----END PGP SIGNATURE-----

--nextPart1900256.WvqENPmUIs--
