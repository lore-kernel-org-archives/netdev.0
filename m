From: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri, 9 Jul 2010 08:12:39 -0700
Message-ID: <20100709081239.4eb8fddd@virtuousgeek.org>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
	<AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>,
	Dave Airlie <airlied-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
	Enrico Bandiello <enban-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>,
	Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2010 18:34:25 -0700
Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> > Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bu=
g.cgi?id=3D16307
> > Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : i915 in kernel 2.6.35-rc3, hi=
gh number of wakeups
> > Submitter =C2=A0 =C2=A0 =C2=A0 : Enrico Bandiello <enban-c0jvKHQHzSy7MTZChrCvtQ@public.gmane.org=
es>
> > Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-26 16:57 (1=
3 days old)
> > Message-ID =C2=A0 =C2=A0 =C2=A0: <4C26317A.5070309-c0jvKHQHzSzx4jp4WZvp5g@public.gmane.org>
> > References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel=
&m=3D127757403404259&w=3D2 =20
>=20
> I don't think anybody noticed this one. Jesse?

Oh I hadn't seen that...  Enrico, can you bisect this issue?  It could
be some spurious hotplug events or possibly a stuck vblank interrupt...

> > Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bu=
g.cgi?id=3D16265
> > Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : Why is kslowd accumulating so=
 much CPU time?
> > Submitter =C2=A0 =C2=A0 =C2=A0 : Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
> > Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-09 18:36 (3=
0 days old)
> > First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad=
057b654d56972acf58c
> > Message-ID =C2=A0 =C2=A0 =C2=A0: <E1OMQ88-0002a1-Gb-UK71uKi2zitAjzmPenPY9A@public.gmane.org=
rg>
> > References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel=
&m=3D127610857819033&w=3D4 =20
>=20
> Dave, Jesse?

I haven't looked at the switchable graphics stuff, hopefully Dave has
an idea here.

> Fixed by commit f4985dc714d7.
>=20
> > Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bu=
g.cgi?id=3D16228
> > Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : BUG/boot failure on Dell Prec=
ision T3500 (pci/ahci_stop_engine)
> > Submitter =C2=A0 =C2=A0 =C2=A0 : Brian Bloniarz <phunge0-PkbjNfxxIASIwRZHo2/mJg@public.gmane.org=
m>
> > Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-16 17:57 (2=
3 days old)
> > Handled-By =C2=A0 =C2=A0 =C2=A0: Bjorn Helgaas <bjorn.helgaas-zDltkPw22Qs@public.gmane.org=
m> =20
>=20
> This has a butt-ugly suggested patch that certainly won't be applied.
> I saw the thread, but lost sight of it. Jesse, did that end up with
> some resolution?

I'll follow up with Yinghai, we were pretty clear about what we wanted
from that patch.

> > Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bu=
g.cgi?id=3D16179
> > Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2.6.35-rc2 completely hosed o=
n intel gfx?
> > Submitter =C2=A0 =C2=A0 =C2=A0 : Norbert Preining <preining@logic.a=
t>
> > Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-06-06 11:55 (3=
3 days old)
> > Message-ID =C2=A0 =C2=A0 =C2=A0: <20100606115534.GA9399-DqSSrKF0TaxD4ZLkIoI8Yg@public.gmane.org=
=2Etuwien.ac.at>
> > References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel=
&m=3D127582534931581&w=3D2 =20
>=20
> Hmm. That one is the vt.c bug coupled with another problem, which in
> turn got opened as a separate bugzilla entry:
>=20
>    http://bugzilla.kernel.org/show_bug.cgi?id=3D16252
>=20
> which in turn then got closed. I dunno.

Yeah, this is weird.  Norbert, do you still see this?  Have you tried
to bisect it?


--=20
Jesse Barnes, Intel Open Source Technology Center
