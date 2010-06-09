From: Carl Worth <cworth-4HiWtcSh4w0dnm+yROfE0A@public.gmane.org>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Tue, 08 Jun 2010 19:38:11 -0700
Message-ID: <87hbldhqwc.fsf@yoom.home.cworth.org>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera> <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>,
	Venkatesh Pallipadi <venki-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Jens Axboe <jaxboe@fusionio.c
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1006081814240.4506-GpypE611fyS63QaFMGN2QEqCLAeBNdoH@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

On Tue, 8 Jun 2010 18:53:55 -0700 (PDT), Linus Torvalds <torvalds@linux-fou=
ndation.org> wrote:
> And some of them do seem to be bisected to likely culprits and/or have=20
> patches that are claimed to have fixed them.
>=20
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16163
> > Subject	: [2.6.35-rc1 Regression] i915: Commit cfecde causes VGA to sta=
y off
> > Submitter	: David John <davidjon-XRr60H37pjdAfugRpC6u6w@public.gmane.org>
> > Date		: 2010-06-02 12:52 (7 days old)
> > Message-ID	: <4C065423.3000202-XRr60H37pjdAfugRpC6u6w@public.gmane.org>
> > References	: http://marc.info/?l=3Dlinux-kernel&m=3D127548313828613&w=
=3D2
>=20
> That has a "reverting the commit fixes it", and a confirmation from Nick=
=20
> Bowler.
>=20
> Eric, Carl: should I just revert that commit? Or do you have a fix?

I'm not aware of any real fix here. That commit isn't supposed to change
much, but it clearly unmasks some broken driver code.

So reverting it for now to hide the broken code from poor users does
seem a good plan to me, (unless Eric has any updates or alternate
suggestions).

=2DCarl

=2D-=20
carl.d.worth-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFMDv6T6JDdNq8qSWgRAm2CAJ9p30+Roeli4N7Gv4rKjfxQKvMIOgCeOZfE
GPPsJXno4b3GCgHuFmrqKk8=
=2APO
-----END PGP SIGNATURE-----
--=-=-=--
