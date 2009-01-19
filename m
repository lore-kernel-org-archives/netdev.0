From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: [2.6.29-rc2 regression] e100: netconsole not functional because of missing firmware
Date: Mon, 19 Jan 2009 21:43:00 +0300
Message-ID: <200901192143.02853.arvidjaar@mail.ru>
References: <200901171908.28533.arvidjaar@mail.ru> <4807377b0901191030g27efac79rbd39501eb2eea4cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2377820.Mrk3YsPs4E";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.soutceforge.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756932AbZASSns@vger.kernel.org>
In-Reply-To: <4807377b0901191030g27efac79rbd39501eb2eea4cb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2377820.Mrk3YsPs4E
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 19 =D1=8F=D0=BD=D0=B2=D0=B0=D1=80=D1=8F 2009 21:30:01 Jesse Brandeburg w=
rote:
> On Sat, Jan 17, 2009 at 8:08 AM, Andrey Borzenkov <arvidjaar@mail.ru>=20
wrote:
> > [    2.008509] e100: eth0: e100_request_firmware: Failed to load
> > firmware "e100/d101m_ucode.bin": -22
> > [    2.010461] netconsole: failed to open eth0
> > [    2.010996] netconsole: cleaning up
> >
> > This has been working all the time without requiring any external
> > firmware to be present. Why it suddenly refuses to work now?
>
> to use netconsole you probably need to set config option
> CONFIG_FIRMWARE_IN_KERNEL=3Dy
>

Yes, I already figured that much :) Unfortunately, there seems to be a=20
bug that prevents compiling firmware if src !=3D obj. At least it does not=
=20
work for me.

> Hm, I wonder if we couldn't have netconsole=3Dy select
> CONFIG_FIRMWARE_IN_KERNEL in Kconfig
>

That probably is overkill; unfortunately I am afraid there is no way to=20
make kconfig automatically select correct firmware in case e100 is built=20
in. =20

Thank you!

--nextPart2377820.Mrk3YsPs4E
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkl0ybYACgkQR6LMutpd94wfvgCbBNZlgCDYBpBLAawXQ2eCSsrR
DtsAoKslTI/pnkPKRj/djHLbiYEJCojY
=6fdT
-----END PGP SIGNATURE-----

--nextPart2377820.Mrk3YsPs4E--
