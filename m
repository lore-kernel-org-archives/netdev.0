From: Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH] mac80211_hwsim: release driver when
 ieee80211_register_hw fails
Date: Wed, 29 Oct 2014 07:45:01 +0100
Message-ID: <20141029064501.GB2985@piware.de>
References: <1414459907-7509-1-git-send-email-eternal.n08@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="tsOsTdHNUZQcU9Ye"
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Junjie Mao <eternal.n08@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414459907-7509-1-git-send-email-eternal.n08@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Acked-By: Martin Pitt <martin.pitt@ubuntu.com>

Hello Junjie,

Junjie Mao [2014-10-28  9:31 +0800]:
> The driver is not released when ieee80211_register_hw fails in
> mac80211_hwsim_create_radio, leading to the access to the unregistered (a=
nd
> possibly freed) device in platform_driver_unregister:

Many thanks for fixing this! Sorry about that, I don't know these bits
very well.

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--tsOsTdHNUZQcU9Ye
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJUUIztAAoJENFO8V2v4RNHxvYP/RpRyrl6WZI3g345T4ceq6K6
jqBkycBTZMqyLxRsFYWUL87A8YLCqgfWG7YQ0hoKZqk5levarhAW6Sf/LAUfgdQZ
aldWyPBu1dCxYKCVnbbjTf07m/9dZRgvtcMhUsJJ3nNwnpBpNy/C2rFbE6hfyp1z
LjyO6o8/0aruPZaUtDro2OkcFQfZU4zbKHlsUp6jtVSuDwca7plzNt+3nJp41iBy
2pEeD0bNBFC1kN2sh1wneHY0UVyPrLAQZ0Oxt9gaKLICENpLROfCrwpMGHM2aV7k
I1phdbJ08ELhKMiuUgSYi3DoVFq5QHS8D9+xK0L3+ZfAUAJD6nCj2JoMKBxWeFc6
z+Q4HtsZ0I7wyBeoST6rcK0Xq2lxBMq7jFuozWUnp2GcPXQB8K4/IYbK3IlHJw05
gWXjsumz64R0pxd2862XiQTlcpn9dOOZFV8fhyxJIgZqNgUFF/q4KwnaYuYOHx81
I43U/EYIuVXZvvCojnNVJ1cKaq771pF8Nd+BNOw3SBjYghj+jaKHCKGjIGXpHpwq
+t5Yiz6BiBuToPkGth5JqkZOiWDaBDkN49CSBvCFu4TZaYM3SWj/Syud+NXUMWYT
Wk3Wv9cVUM4N/QrhjCsqZIjNBGos7+znYyfeYlBiV6MKtArmSbqVl7Y3sG+Hvv6R
UX0JIXEya5TcvPq2RRih
=qSZx
-----END PGP SIGNATURE-----

--tsOsTdHNUZQcU9Ye--
