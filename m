From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC/HACK] net/compat/wext: allow sending different messages
 to compat tasks
Date: Wed, 24 Jun 2009 10:48:35 +0200
Message-ID: <1245833315.21314.47.camel@johannes.local>
References: <1245589835.5003.2.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-vT0sr91OMfl2dOhgrsVY"
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33661 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbZFXIsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 04:48:35 -0400
In-Reply-To: <1245589835.5003.2.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vT0sr91OMfl2dOhgrsVY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-06-21 at 15:10 +0200, Johannes Berg wrote:
> Wireless extensions have the unfortunate problem that events
> are multicast, and are not independent of pointer size. Thus,
> currently 32-bit tasks on 64-bit platforms cannot properly
> receive events and fail with all kinds of strange problems,
> for instance wpa_supplicant never notices disassociations, due
> to the way the 64-bit event looks to a 32-bit process the fact
> that the address is all zeroes is lost, it thinks instead it
> is 00:01:00:00:00:00 (actually I'm not entirely sure about the
> position of the 1 but it's like that).

No further comments on this? If I fix sparc and mips, can I get it
merged?

johannes

--=-vT0sr91OMfl2dOhgrsVY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKQehfAAoJEODzc/N7+QmapqkP/i2cik9RB8+iyzK7uThbMsgo
v6RYaOFo6t6TRRTccxdJbFs9c9RtTVoF/t8aiDGo1rrEtZE9FV+P5WAH55D8TkZB
t+v0LMJm1HVgf2jQyS1IpEa21+djSM0FEr7UsgHWGsVxDGo5juagIRuSn8YCl3Or
oJPwcNVvjP0NhfqYfEcZg3k2d2vDBdTtA/S04u64dNBJH3jgQnwPtS1eaP6RoXA7
f8ZvNV2Yb0K1ieZdIaorU2fzYID7OwhhrZs2t4EMnn4XAaHZvwowmZWGbBigjtwy
iHx8TMS43MqD45HMau3mNu4vj5JUtcUVD9gF6PwKmhHNpuu1g1NMC28QoMvqL21S
nHQVGwRyjyuvlBZpCSsVLrBnalVUKtrrB4k23TjmMGoYyMfHit1Q/Ysz6RPjGoY1
EgScHhIPIqgD7J9RnsG3Zr16PclExLJT3oBrdAq++thiIl/NNAXS9Omma+jmCtE7
EDqAcrs48+EmoQZayUTLyICyk/lmVO7upf1mznDapraHhUYriElYeBxhFD/mOCnP
KOVml38jYgJZDeXH2UC+2cX5IAtiGa8GNQefmOpiBTnL1803FouCoLktlp+Hgn3K
eWC6FAKi8pDwjE3q3OcL5mXuzNN3wp1qrbxfA2q1VMD002j+gJtfreaP6RY5hfDC
ZEIr+Gt3WErtOdAAyxI0
=Ea06
-----END PGP SIGNATURE-----

--=-vT0sr91OMfl2dOhgrsVY--

