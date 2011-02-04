From: Keith Packard <keithp@keithp.com>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 03 Feb 2011 17:41:45 -0800
Message-ID: <yun62t08tk6.fsf@aiko.keithp.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera> <AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com> <s5haaid3xos.wl%tiwai@suse.de> <201102032009.17100.rjw@sisk.pl> <AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com> <AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com> <AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com> <AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com> <yund3n88v7x.fsf@aiko.keithp.com> <AANLkTin-9a5Z3qq4t8UakRvgB1G3_CT2RLKMVaHXvnLr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Dave Airlie <airlied@gmail.com>, Carlos Mafra <crmafra2@gmail.com>,
	Dave Airlie <airlied@redhat.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Takashi Iwai <tiwai@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <AANLkTin-9a5Z3qq4t8UakRvgB1G3_CT2RLKMVaHXvnLr@mail.gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

On Thu, 3 Feb 2011 17:11:14 -0800, Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:

> Ok, patch looks sane, but it does leave me with the "what about the
> 'fb_changed' case?" question. Is that case basically guaranteed to not
> change any existing dpms state?

None of the existing drivers turn anything on or off in the
mode_set_base code; the fix I intended was purely for the mode_set case,
which always turns on all of the connected outputs. I just screwed up
and stuck it in the wrong place.

=2D-=20
keith.packard@intel.com

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFNS1lZQp8BWwlsTdMRAq4xAKCmvgLGzkdddOriz6OWcdaSb+lJoACfcCkY
fBAkVrOR6oELMkpir6YZlYk=
=brEL
-----END PGP SIGNATURE-----
--=-=-=--
