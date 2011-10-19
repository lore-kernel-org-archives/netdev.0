From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: BUG: All network processes hang (brcmsmac/wpa_supplicant)
Date: Wed, 19 Oct 2011 16:43:27 +0200
Message-ID: <4E9EE20F.1030403__7601.78671121157$1319035449$gmane$org@broadcom.com>
References: <20111019123602.GA11883@schottelius.org>
 <1319028563.8416.1.camel@edumazet-laptop>
 <20111019130749.GD11883@schottelius.org>
 <20111019142837.GA1414@schottelius.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=------------enig96DA4F0351AA0862B9EF1ACB;
 micalg=pgp-sha1;
 protocol="application/pgp-signature"
Cc: wey-yi.w.guy@intel.com
To: "Nico Schottelius" <nico-linux-20111017@schottelius.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireles
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2701 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab1JSOnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 10:43:46 -0400
In-Reply-To: <20111019142837.GA1414@schottelius.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------enig96DA4F0351AA0862B9EF1ACB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/19/2011 04:28 PM, Nico Schottelius wrote:
> Triggered it!=20
>=20
> And also got the traceback!
>=20
> Dmesg + log attached, let me know when I can pull the fix from
> somewhere.
>=20
> Cheers,
>
> Nico
>=20

I actually don't see the rtnl_lock or mutex_lock that was listed in your
original dmesg. There are a lot of warning traces from mac80211.c.

The other interesting thing is the following:

[  367.389096] wlan0: deauthenticating from 00:03:52:e3:0e:10 by local
choice (reason=3D3)
[  367.416312] cfg80211: Calling CRDA to update world regulatory domain
[  369.367667] wlan0: direct probe to 00:03:52:2c:01:00 (try 1/3)
[  369.565008] wlan0: direct probe to 00:03:52:2c:01:00 (try 2/3)
[  369.764891] wlan0: direct probe to 00:03:52:2c:01:00 (try 3/3)
[  369.964768] wlan0: direct probe to 00:03:52:2c:01:00 timed out
[  381.310339] wlan0: direct probe to 00:0f:61:1a:0c:50 (try 1/3)
[  381.508071] wlan0: direct probe to 00:0f:61:1a:0c:50 (try 2/3)
[  381.707955] wlan0: direct probe to 00:0f:61:1a:0c:50 (try 3/3)
[  381.907788] wlan0: direct probe to 00:0f:61:1a:0c:50 timed out
[  393.250073] wlan0: direct probe to 00:03:52:2c:01:00 (try 1/3)
[  393.447810] wlan0: direct probe to 00:03:52:2c:01:00 (try 2/3)
[  393.647700] wlan0: direct probe to 00:03:52:2c:01:00 (try 3/3)
[  393.847576] wlan0: direct probe to 00:03:52:2c:01:00 timed out
[  405.183177] wlan0: direct probe to 00:0f:61:1a:1d:30 (try 1/3)
[  405.380906] wlan0: direct probe to 00:0f:61:1a:1d:30 (try 2/3)
[  405.580773] wlan0: direct probe to 00:0f:61:1a:1d:30 (try 3/3)
[  405.780658] wlan0: direct probe to 00:0f:61:1a:1d:30 timed out

There is another thread title "iwlagn is getting very shaky". It makes
me wonder.

Where did you get your kernel from. From you dmesg I see:

Linux version 3.1.0-rc6-gbee709a (nico@brief)

I tried to locate the SHA1 bee709a but it is not in my repository. I
want to look what the warnings from mac80211 mean.

Gr. AvS


--------------enig96DA4F0351AA0862B9EF1ACB
Content-Type: application/pgp-signature;
 name=signature.asc
Content-Description: OpenPGP digital signature
Content-Disposition: attachment;
 filename=signature.asc
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJOnuIUAAoJELcEx/G14aEWXyAP/j+jSfK8mRMo48zG+308Ob9d
gjuLfF31H9P/mdiuABuwilOlenfRnLrw76yxx2/fISry/KhGNevDR2rdIAFdEBqC
j/4ffKg3kvm7LEjgt4BvSJ95aFZfbQBvklEd5NdTmgndj/R3quzYkyq+/NGtHddG
A6pITxR/TjF6xK9QR0ooqF3L2pBRu97mSLTQ2V7Dg3ZXX+jrsHhk4JLu4awON7lL
HQG1fz7v1oC7bemYXpdQo9s8Xg0/w/kAirtyHXdMNLeqgqxZwK3G5Gn87rrAG4zJ
hP9twle9RKo+/6HH4xFwc+VOchGbHf6wFyRflPlOBCvD2wpeCz8nFi1iaINT8MSU
XCv7PU5vpZoBabFpqIQ3sfwDDiNbv5SXvIE/as0HY2Jvpih+yQrLyGGH9Jo3dv8k
0iS+PLrTjKbpcrSBkePzEcS0WMgVx2t7HPfA1uXTo97ZGGAWiQbubSsW/4iRbmZ7
KOffrL6bbnRCIfphJkB3xyObJZbiG9FYStjXuoaKc5Edpq1+uCwH+u0JY3ceM3S3
hKjTOrIsRd5jkPHGV8SIXqLwvARfbO2iQvQOxhmCaZP2OKD16sb1MaaaNL1F7TSj
F+93yf19/Cf08jk24VDqECiR38oTWJttOxTlJbbAKDesTjk7WIgbSOfqoEoKVoE1
Mf5tRURbSL3M1Fh3GlB/
=2tib
-----END PGP SIGNATURE-----

--------------enig96DA4F0351AA0862B9EF1ACB--
