From: Michal Vanco <vanco@satro.sk>
Subject: Re: e1000 packet corruption problem
Date: Wed, 06 Apr 2005 16:27:17 +0200
Message-ID: <4253F1C5.2090203@satro.sk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4B8D84CEE253ECADAA3D4E31"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4B8D84CEE253ECADAA3D4E31
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hello,

I've made some more testing. This one was pretty surprising:

>From 192.168.0.2:

# sudo ping 192.168.0.1 -p fefffefffefffeff -i 0.01 -c 100
100 packets transmitted, 100 received, 0% packet loss, time 901ms

# sudo ping 192.168.0.1 -p fffefffefffefffe -i 0.01 -c 100
100 packets transmitted, 18 received, 82% packet loss, time 1068ms

Any ideas of how to solve this?

regards,
michal

--------------enig4B8D84CEE253ECADAA3D4E31
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCU/HI2/VqJwUsLAMRAovXAKCmFiyuXZJ1Xd1oO43U94V5zorX0QCeMJ7b
w16LIMIw8AibB+fZ4KOdCp8=
=aRIa
-----END PGP SIGNATURE-----

--------------enig4B8D84CEE253ECADAA3D4E31--
