From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH] remove historic entries in Documentation/Changes
Date: Sun, 2 Nov 2003 09:58:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031102085835.GH1536@sunbeam.de.gnumonks.org>
References: <20031029.012202.105420248.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aF3LVLvitz/VQU3c"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20031029.012202.105420248.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--aF3LVLvitz/VQU3c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Yoshifuji!

Please consider the following update for netfilter/iptables, instead of
removing any reference to it.

--- linux-old/Documentation/Changes	2003-09-29 21:20:11.000000000 +0200
+++ linux/Documentation/Changes	2003-11-02 09:56:09.000000000 +0100
@@ -237,13 +237,15 @@
 General changes
 ---------------
=20
-The IP firewalling and NAT code has been replaced again.  The new
-netfilter software (including ipfwadm and ipchains backwards-
-compatible modules) is currently distributed separately.
-
 If you have advanced network configuration needs, you should probably
 consider using the network tools from ip-route2.
=20
+Packet Filter / NAT
+-------------------
+The packet filtering and NAT code uses the same tools like the previous 2.=
4.x
+kernel series (iptables).  It still includes backwards-compatibility modul=
es
+for 2.2.x-style ipchains and 2.0.x-style ipfwadm.
+
 PPP
 ---
=20
@@ -400,11 +402,9 @@
 ---------
 o  <http://sourceforge.net/project/showfiles.php?group_id=3D14>
=20
-Netfilter
----------
-o  <http://netfilter.filewatcher.org/iptables-1.2.tar.bz2>
-o  <http://netfilter.samba.org/iptables-1.2.tar.bz2>
-o  <http://netfilter.kernelnotes.org/iptables-1.2.tar.bz2>
+Iptables
+--------
+o  <http://www.iptables.org/downloads.html>
=20
 Ip-route2
 ---------

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--aF3LVLvitz/VQU3c
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/pMc7XaXGVTD0i/8RAmDRAJ49qfDwKFF2UtCIjbkj/TietFzzeACePjPS
EJbFH95MuNC4KJzCm4cm9ds=
=Emx2
-----END PGP SIGNATURE-----

--aF3LVLvitz/VQU3c--
