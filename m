From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH -next] net: fix Makefile typos & build errors
Date: Tue, 30 Aug 2011 11:59:25 +1000
Message-ID: <20110830115925.45984bb8eeb73401dd5d289f@canb.auug.org.au>
References: <20110829161907.19232776e65389dea1caa7e8@canb.auug.org.au>
	<20110829114940.4d29febc.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__30_Aug_2011_11_59_25_+1000_Nyg/YomqZxbT3nSF"
Cc: netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110829114940.4d29febc.rdunlap@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__30_Aug_2011_11_59_25_+1000_Nyg/YomqZxbT3nSF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 29 Aug 2011 11:49:40 -0700 Randy Dunlap <rdunlap@xenotime.net> wrot=
e:
>
> @@ -44,10 +44,10 @@ obj-$(CONFIG_PPP_SYNC_TTY) +=3D ppp/
>  obj-$(CONFIG_PPPOE) +=3D ppp/
>  obj-$(CONFIG_PPPOL2TP) +=3D ppp/
>  obj-$(CONFIG_PPTP) +=3D ppp/
> -onj-$(CONFIG_SLIP) +=3D slip/
> +obj-$(CONFIG_SLIP) +=3D slip/
>  obj-$(CONFIG_SLHC) +=3D slip/
>  obj-$(CONFIG_NET_SB1000) +=3D sb1000.o
> -onj-$(CONFIG_SLIP) +=3D slip/
> +obj-$(CONFIG_SLIP) +=3D slip/

It may be my old(er) eyes, but isn't that CONFIG_SLIP line repeated?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__30_Aug_2011_11_59_25_+1000_Nyg/YomqZxbT3nSF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOXEP9AAoJEDMEi1NhKgbsi0IH/ApkE+VVuc7zKPWNrotpX1ov
o91AJ24Vr/PTY+z475vKYlr5JpMIroUjnmd8rvnAI4d0upSSxp+ODXOpqQC+1UcX
uszINsYeIOt9mAAvaLKgkdHR24vDMdJNnhqWp0dWGejGxEtF19txcpeaeg6jGwFp
J43Kv/h7uKXbq0M4Nc6scDkGoz9EGm9NzWJj0+4/KtxxN7hIJEQfw0Xh5GcMWb1N
+SoGS+1pQOiiH7clUI+Nhv2uINMUyssI2KovHEnnjwiQ0mp6sYrhGhCW7aCQvtK4
OloLn7Co/VIdbXxRRSUJ/jc1BdcAKdF3b5XIVRz76U679PtBPUE+NKQRAYf8R7g=
=EKgZ
-----END PGP SIGNATURE-----

--Signature=_Tue__30_Aug_2011_11_59_25_+1000_Nyg/YomqZxbT3nSF--
