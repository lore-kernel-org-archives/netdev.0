From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Wed, 26 Apr 2006 23:25:42 +0200
Message-ID: <20060426212542.GA9287@zion.homelinux.com>
References: <20060421010809.6c3cfc34.akpm@osdl.org> <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com> <200604220202.59434.ak@suse.de> <20060424074148.GB23340@zion.homelinux.com> <Pine.LNX.4.64.0604260126020.12542@pc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Cc: Andi Kleen <ak@suse.de>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:30174 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S964878AbWDZVZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 17:25:54 -0400
To: Nuri Jawad <lkml@jawad.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0604260126020.12542@pc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 26, 2006 at 02:36:18AM +0200, Nuri Jawad told us:
> Did you create a high load on the system in the manner I described?
> The bug once only appeared after about 6 hours here when line + CPU had=
=20
> been mostly idle. But that was the longest time between failures. Can you=
=20
> test with one of the 2.6.16 kernels I tried (latest was .9)? Can't say=20

Unfortunately it seems like plain 2.6.16.x doesn't like the ide
controller on my (VIA) mainboard, I'm getting I/O errrors on hda
when booting this kernel (but hard drive works ok with -mm) :-(
actually I haven't been running a plain stable kernel for a while,
I've been running -mm kernels for ages...


Sven

> for sure if CPU load is a factor, load on the connection seems to be.

--=20
Linux zion.homelinux.com 2.6.17-rc1-mm1_31 #31 Sat Apr 8 16:18:23 CEST 2006=
 i686 athlon i386 GNU/Linux
 23:16:15 up  3:58,  2 users,  load average: 0.83, 0.82, 0.79

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFET+VWo4FAdB2PneQRAv1xAJ4x8GEbuCoNONNM7us4MIpDN92aiQCdGwrb
gzYDvqE34sOTkkiwZXB3EJM=
=gAAz
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
