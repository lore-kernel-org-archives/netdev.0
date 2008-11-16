From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.28-rc5: Reported regressions from 2.6.27
Date: Sun, 16 Nov 2008 10:43:29 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0811161030070.3468@nehalem.linux-foundation.org>
References: <VwdsQNEjR_C.A.CiD.9_FIJB@chimera>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VwdsQNEjR_C.A.CiD.9_FIJB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Sun, 16 Nov 2008, Rafael J. Wysocki wrote:
>
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12049
> Subject		: Oops in acpi_system_wakeup_device_seq_show
> Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
> Date		: 2008-11-16 13:04 (1 days old)
> First-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0794469da3f7b2093575cbdfc1108308dd3641ce
> References	: http://marc.info/?l=3Dlinux-kernel&m=3D122684070215520&w=
=3D4

This already got fixed: commit 77fb61a04a0483ad274ce5c51b02c46c12db3693=
=2E

> Regressions with patches
> ------------------------
>=20
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12042
> Subject		: USB hid blocks USB port in 2.6.28rc3
> Submitter	: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
> Date		: 2008-11-11 0:31 (6 days old)
> References	: http://marc.info/?l=3Dlinux-usb&m=3D122636246522848&w=3D=
4
> Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
> 		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122661425620251&w=3D2

commit 131d3a7a009d56a96cc7117b4e9d0c90c2e2a1dc

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11954
> Subject		: sysprof tracer ABI regression in 2.6.28rc1
> Submitter	: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
> Date		: 2008-11-04 22:14 (13 days old)
> Handled-By	: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>
> Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18683&action=3D=
view

commit 072ba49838b42c873c496d72c91bb237914cf3b6

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11911
> Subject		: new PCMCIA device instance after resume - orinoco can't do=
wnload firmware
> Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
> Date		: 2008-10-28 19:19 (20 days old)
> References	: http://marc.info/?l=3Dlinux-wireless&m=3D122522165719760=
&w=3D4
> Handled-By	: Dave <kilroyd-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> Patch		: http://marc.info/?l=3Dlinux-wireless&m=3D122539058601588&w=3D=
4

commit e689597fe890cf22e23195037aa668c39b25ae4b

			Linus
