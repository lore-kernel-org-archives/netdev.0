From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.28-rc5: Reported regressions from 2.6.27
Date: Sun, 16 Nov 2008 20:28:33 +0100
Message-ID: <200811162028.34099.rjw@sisk.pl>
References: <VwdsQNEjR_C.A.CiD.9_FIJB@chimera> <alpine.LFD.2.00.0811161030070.3468@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0811161030070.3468@nehalem.linux-foundation.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday, 16 of November 2008, Linus Torvalds wrote:
>=20
> On Sun, 16 Nov 2008, Rafael J. Wysocki wrote:
> >
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12049
> > Subject		: Oops in acpi_system_wakeup_device_seq_show
> > Submitter	: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
> > Date		: 2008-11-16 13:04 (1 days old)
> > First-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torva=
lds/linux-2.6.git;a=3Dcommit;h=3D0794469da3f7b2093575cbdfc1108308dd3641=
ce
> > References	: http://marc.info/?l=3Dlinux-kernel&m=3D122684070215520=
&w=3D4
>=20
> This already got fixed: commit 77fb61a04a0483ad274ce5c51b02c46c12db36=
93.
>=20
> > Regressions with patches
> > ------------------------
> >=20
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12042
> > Subject		: USB hid blocks USB port in 2.6.28rc3
> > Submitter	: Andi Kleen <andi@firstfloor.org>
> > Date		: 2008-11-11 0:31 (6 days old)
> > References	: http://marc.info/?l=3Dlinux-usb&m=3D122636246522848&w=3D=
4
> > Handled-By	: Alan Stern <stern@rowland.harvard.edu>
> > 		  Jiri Slaby <jirislaby@gmail.com>
> > Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122661425620251&w=3D=
2
>=20
> commit 131d3a7a009d56a96cc7117b4e9d0c90c2e2a1dc
>=20
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11954
> > Subject		: sysprof tracer ABI regression in 2.6.28rc1
> > Submitter	: Eric Anholt <eric@anholt.net>
> > Date		: 2008-11-04 22:14 (13 days old)
> > Handled-By	: Eric Anholt <eric@anholt.net>
> > Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18683&actio=
n=3Dview
>=20
> commit 072ba49838b42c873c496d72c91bb237914cf3b6
>=20
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11911
> > Subject		: new PCMCIA device instance after resume - orinoco can't =
download firmware
> > Submitter	: Andrey Borzenkov <arvidjaar@mail.ru>
> > Date		: 2008-10-28 19:19 (20 days old)
> > References	: http://marc.info/?l=3Dlinux-wireless&m=3D1225221657197=
60&w=3D4
> > Handled-By	: Dave <kilroyd@googlemail.com>
> > Patch		: http://marc.info/?l=3Dlinux-wireless&m=3D122539058601588&w=
=3D4
>=20
> commit e689597fe890cf22e23195037aa668c39b25ae4b

Thanks a lot, closed all of them.

Best,
Rafael
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
