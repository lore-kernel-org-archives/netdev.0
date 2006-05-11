From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space
	clientMLME
Date: Thu, 11 May 2006 13:41:04 +0200
Message-ID: <1147347664.9630.3.camel@johannes>
References: <20060502211817.GA30842@instant802.com>
	 <20060503182815.1a9ebb5e@griffin.suse.cz>
	 <20060503164458.GB10524@instant802.com>
	 <1146745613.1137.28.camel@localhost>
	 <20060510171749.GH23571@instant802.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FxuaTM3I0gCWJHLF/eLL"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2443 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030231AbWEKLmL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 07:42:11 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060510171749.GH23571@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-FxuaTM3I0gCWJHLF/eLL
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-05-10 at 10:17 -0700, Jouni Malinen wrote:

> This is still somewhat open, but at minimum, there needs to be a
> mechanism for receiving and sending management frames from user space.
> d80211 uses a "management netdev" for this currently (the same one that
> was used before with hostapd for AP mode). In addition to that,
> wpa_supplicant expect to be able to read list of support channels and TX
> rates (get_hw_feature_data handler in driver wrapper) and to be able to
> add and remove STA entries (e.g., for TX rate control and association
> status validation in kernel code).

Right.

> Currently, scanning is done simply by setting the channel with
> SIOCSIWFREQ and listening for management frames. However, the goal is to
> provide simple atomic operations that user space programs can request
> the kernel code to do. This would cover not only scanning, but also some
> other needs like IEEE 802.11k radio measurements. These operations could
> be something like "stop transmit, move to channel 5, report received
> management frames, record noise level, do this for 5 ms, return to
> operational channel, enable transmit".

Yeah, we talked about that. I suppose softmac will never support the
current interface, we'll just design a new one and use that.

johannes

--=-FxuaTM3I0gCWJHLF/eLL
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARGMizaVg1VMiehFYAQLFEQ//XNJ6y0b+H7cUNm8W8bRWjubMEXMotTCw
nbA0H1iBcb/8FR0x1q/3PCcXP8wDh/+zahySuxNEY3LlPaHpJ1YMp/UDuxgPwluq
4EGQ8ScvfOX//pTnH3Wcd558/MdNfdYYDP31AkFKtvqX9Ac51+ckL3i/3zA7fBrS
NxTgTAtlYz+XJQO2gQI7i5wgEclJIh21LqZp+gI4P1XmJba6wwF80IsTK8UN/yKC
i5wq5XK1Li4pawZRQWN2caqPf04vbRBUHRBqOFmz/uDiyZOhT4oklkM7zBmA6+kw
oqJmgWs7Gh5e7MmagwDh0IknUAAvYRje83vLs2VV/24PX2imr+7y4MYDnJcyY1Vf
31NkiJjdu+8WEGZ1TgbFLlFdkTeJb1cgqdTt0ifgxlHVQeJEtKwUCFMWfh0Lgohw
M8NOBj176cava0un8yw7cQO+CwEtWLH7YI+Hw6c2DAJJJ5/ZvqZMVeV76g+StZGn
CW+QCBmz1Ntm5iUtN8VYoaFXc4q3+Cs9N0Lx8YLrFFVwRjf06nwKi5EAWkMBnwHQ
zQYgnGjd2930yFw0iaYYhSCk21dT16LxWCrbgtasc4jR51vtyJ1YqYsZGEC/OIPj
n78GG8CFIm5rhv8YdTx9qcX038wQBMhkWlSPJW8kEoaR+iBXiIHuyVuyj/2m0OX7
9ezhWgI8yto=
=Leuy
-----END PGP SIGNATURE-----

--=-FxuaTM3I0gCWJHLF/eLL--

