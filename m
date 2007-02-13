From: "Hesse, Christian" <mail-8oMOrB1mGocUSW6y5lq3GQ@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Tue, 13 Feb 2007 13:18:33 +0100
Message-ID: <200702131318.38027.mail@earthworm.de>
References: <45CCE3CA.4050904@linux.intel.com> <200702101525.56820.mail@earthworm.de> <45D0B363.8070303@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1513687.nBdbPG6PMV";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45D0B363.8070303-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1513687.nBdbPG6PMV
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 12 February 2007 19:35, James Ketrenos wrote:
> Hesse, Christian wrote:
> > On Saturday 10 February 2007 14:23, Hesse, Christian wrote:
> >> On Friday 09 February 2007 22:12, James Ketrenos wrote:
> >>> We are pleased to announce the availability of a new driver for the
> >>> Intel PRO/Wireless 3945ABG Network Connection adapter.
>
> ...
>
> > Oh, I forgot one note: "make patch_kernel" is terribly broken. Any chan=
ce
> > to get this fixed soon?
>
> I've put up a new version of iwlwifi (0.0.6) with significant changes to
> the patch_kernel scripts as well as including Pavel's patch to KSRC.
>
> I performed some build testing with 2.6.18 and wireless-dev @ commit
> f66e5aaa88c1c0a7ee6c6427d6535ed8afd35427 (Jan 8).
>
> http://intellinuxwireless.org/?n=3Ddownloads
>
> Let me know if it is still breaking.

Hmm, it compiled once, but after I removed the tree and used a clean one I =
can=20
not reproduce it:

LD      drivers/net/wireless/built-in.o
ld: drivers/net/wireless/d80211/built-in.o: No such file: No such file or=20
directory
make[3]: *** [drivers/net/wireless/built-in.o] Error 1
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

So it is still broken.
=2D-=20
Regards,
Chris

--nextPart1513687.nBdbPG6PMV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBF0aydlZfG2c8gdSURAkFAAJ9BGLgPA41ckZrsXTWDZHNo1LEnGgCgsFdA
zve0xVxSF+0d8iyje4+ESO8=
=3wBC
-----END PGP SIGNATURE-----

--nextPart1513687.nBdbPG6PMV--
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
