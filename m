From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 17:51:09 +0200
Message-ID: <1149695470.3925.7.camel@johannes>
References: <4485D66B.7080108@lwfinger.net>
	 <1149682213.3999.14.camel@johannes>  <4486F513.5050906@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-yj5BqJBFsyqUlUBkrox/"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63433 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932257AbWFGPvR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 11:51:17 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <4486F513.5050906@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yj5BqJBFsyqUlUBkrox/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2006-06-07 at 10:47 -0500, Larry Finger wrote:

> I have a little more information on what is happening.=20

Great.

> In IEEE Std 802.11i-2004, which defines the=20
> WPA protocol, Figure 11a shows the sequence of exchanges needed to associ=
ate. Both bcm43xx-softmac=20
> and ndiswrapper go through the "Open System Authentication" process.=20

Right, you always have to do that.

> Where they seem to diverge is=20
> in the STA's "Association Request (Security Parameters)" step. With ndisw=
rapper, the AP responds=20
> with a WPA EAPOL-Key message; whereas with softmac, the AP sends back the=
 "invalid pairwise cipher=20
> message" and rejects the association.

Interesting. That's strange.

> Can anyone point to a reference that states what the content of the Assoc=
iation Request should be to=20
> get the AP to respond with the EAPOL-Key message? Unfortunately, I have n=
o possibility of=20
> implementing a sniffer to see what a "correct" message contains.

Well, it should be shown in the 802.11i spec too.

johannes

--=-yj5BqJBFsyqUlUBkrox/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARIb166Vg1VMiehFYAQISUQ//bY/bNNpO+aKBu3lEkqBmWnNduA8nGq/k
40vCqqjW3sYTp3u0TxPc4uM6qC835zU9Gpsys8VKGokf7e5/jiEVJh+82ID51ecW
2QcZeOinGbRtNb+mi80Zf4R7mIw8tZGU28rvrtdOEgP8D3sFFD0mMK9/lC1TNGKB
Eqaop+jlTEP9A7AYvtRsGJmCYFh7hLcz3bX51dF+nhxfyAmT+buwt6qUeJ5bPYk9
fQLcyXzR3fMw+Y+9keOZRrJW+4whHIziL5lCo6beEBB+326OYN9+Izpx3YFZfC19
0IF8tavBqLJxFPcUcPlDCD6afr3tM1whOiT1lbAAgpl3esuvyV197T/PDW/8iLR/
ifDyAO8MFgTGizxEmk1cuO714S/cjBPf3c6Zidu5aLCspwzhpw5rbPa/3lOtnwTE
u2yGLeo2KiqoNBK4vtJmHCHINlIHB1mJ2gNgx5BnoIpWtWX87dBzOuCSJ18CpVCL
ZS9AmNFzOnX9caiQB326qTVUfmR+U407kYPFofov4nSbw6Wwq148nTOG9TWSuGhG
TpyblPxakMeW+aAr5p4p6oLDMkTZYbrHxwW1ntMrhKjhuEcrEw3AwDNoeJgjH6C5
t9oy9t1mjct/zpP7fdDK10zzaiVWw3XXcT0lYYev0Zoq9/OJjtGVklb0foZAqYq7
x/YlPjDmVug=
=hvck
-----END PGP SIGNATURE-----

--=-yj5BqJBFsyqUlUBkrox/--

