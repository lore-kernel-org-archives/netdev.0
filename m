From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: 2.6.29-rc: unable to compile e100 firmware into kernel
Date: Sun, 1 Feb 2009 22:18:16 +0300
Message-ID: <200902012218.20481.arvidjaar@mail.ru>
References: <200901311900.00851.arvidjaar@mail.ru> <4807377b0902011105l29e846c3r140212ac654efb93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4379491.qMzcQLHoWd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <4807377b0902011105l29e846c3r140212ac654efb93@mail.gmail.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4379491.qMzcQLHoWd
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 1 of February 2009 22:05:43 Jesse Brandeburg wrote:
> On Sat, Jan 31, 2009 at 7:59 AM, Andrey Borzenkov <arvidjaar@mail.ru>=20
wrote:
> > {pts/2}% LC_ALL=3DC make -C ~/src/linux-git
> > O=3D$HOME/build/linux-2.6.29 make: Entering directory
> > `/home/bor/src/linux-git'
> >  Using /home/bor/src/linux-git as source for kernel
> > ln -fsn /home/bor/src/linux-git source
>
> I think (seem to recall something on the list) there have been
> multiple people reporting the make O=3D option doesn't work with
> CONFIG_FIRMWARE_IN_KERNEL, but what does the
> CONFIG_PREVENT_FIRMWARE_BUILD=3Dy option do?  If it does what it
> appears to by its title, looks like you might need to set that to =3Dn

Does not work. Besides, even with CONFIG_PREVENT_FIRMWARE_BUILD=3Dy=20
firmware is built and installed under /lib/firmware when=20
CONFIG_FIRMWARE_IN_KERNEL is not set. It is just that it does not help=20
with netconsole :(


--nextPart4379491.qMzcQLHoWd
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkmF9XwACgkQR6LMutpd94yMZwCeKme3vq7+0UnO7wfx6Jr0A9fP
4NEAnA4VR1bcIWGNEun2MfU/NytZbU8D
=oWC+
-----END PGP SIGNATURE-----

--nextPart4379491.qMzcQLHoWd--
