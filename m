From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 7 Jan 2005 14:14:01 -0600
Message-ID: <200501071414.05126.jeremy.guthrie@berbee.com>
References: <200501031455.26980.jeremy.guthrie@berbee.com> <16862.57504.383176.640058@robur.slu.se> <200501071338.16621.jeremy.guthrie@berbee.com>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5095543.GhOXsq51Cb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200501071338.16621.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart5095543.GhOXsq51Cb
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

I just updated the Intel Drivers to the latest on source-forge(5.6.10.1).  =
I=20
now see lower CPU usage but I am still dropping.

During a 60 second window the machine received 5,110,164 packets and droppe=
d=20
20461 or roughly 0.4% packet loss.

cat /proc/net/softnet_stat
2f9c9bd0 150dc67c 00c4701b 000d2659 00000000 00000000 00000000 00000000=20
00097049
00010f9b 00000000 0000003a 00000000 00000000 00000000 00000000 00000000=20
000002fc
It has been at 150dc67c for a while now.  So while I am dropping at the car=
d,=20
I am not dropping in the stack.

mpstat -P ALL 2
Linux 2.6.10 (h-idspr-msn-1)    01/07/05

14:06:45     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
14:06:47     all    0.00    0.00    0.00    0.75    1.74   43.03   54.48 =20
22598.51
14:06:47       0    0.00    0.00    0.00    0.00    2.49   78.61   18.91 =20
17570.65
14:06:47       1    0.00    0.00    0.00    1.49    1.49    7.46   90.05  =
=20
5023.88

14:06:47     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
14:06:49     all    0.00    0.00    0.00    0.00    1.50   45.75   52.75 =20
19352.00
14:06:49       0    0.00    0.00    0.00    0.00    2.50   83.00   14.50 =20
14467.00
14:06:49       1    0.00    0.00    0.00    0.00    0.50    9.00   90.50  =
=20
4886.50

14:06:49     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
14:06:51     all    0.00    0.00    0.00    0.00    1.75   42.50   55.75 =20
22482.59
14:06:51       0    0.00    0.00    0.00    0.00    2.49   77.61   19.90 =20
17572.64
14:06:51       1    0.00    0.00    0.50    0.00    1.00    6.97   91.54  =
=20
4919.90

14:06:51     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
14:06:53     all    0.00    0.00    0.25    0.00    1.99   43.03   54.73 =20
22458.00
14:06:53       0    0.00    0.00    0.00    0.00    3.00   78.50   18.50 =20
17456.00
14:06:53       1    0.00    0.00    0.00    0.00    0.50    8.00   91.00  =
=20
4992.50

14:06:53     CPU   %user   %nice %system %iowait    %irq   %soft   %idle   =
=20
intr/s
14:06:55     all    0.00    0.00    0.00    0.00    1.75   42.75   55.50 =20
22854.00
14:06:55       0    0.00    0.00    0.00    0.00    3.00   77.00   20.00 =20
17838.00
14:06:55       1    0.00    0.00    0.00    0.00    1.00    8.50   91.00  =
=20
5012.50


=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart5095543.GhOXsq51Cb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD4DBQBB3u2NqtjaBHGZBeURAtWvAKCNruPqTyGJpSYfz/lcul499cbg8ACVGt2b
PTNzJOqIcPfEU58YFq2lfg==
=K52x
-----END PGP SIGNATURE-----

--nextPart5095543.GhOXsq51Cb--
