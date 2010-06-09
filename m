From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Tue, 08 Jun 2010 23:26:09 -0300
Message-ID: <4C0EFBC1.5090401@redhat.com>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera> <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Carl Worth <cworth@cworth.org>,
	Eric Anholt <eric@anholt.net>,
	Venkatesh Pallipadi <venki@google.com>,
	Jens Axboe <jaxboe@fusionio.com>,
	Dave Airlie <airlied@gmail.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ingo Molnar <mingo@elte.hu>,
	=?ISO-8859-15?Q?David_H=E4rdeman?= <david@hardeman.nu>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em 08-06-2010 22:53, Linus Torvalds escreveu:

>=20
>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16037
>> Subject	: NULL Pointer dereference in __ir_input_register/budget_ci_=
attach
>> Submitter	: Sean Finney <seanius@debian.org>
>> Date		: 2010-05-23 19:52 (17 days old)
>=20
> Perhaps related to commit 13c24497086418010bf4f76378bcae241d7f59cd?
>=20
> David H=E4rdeman, Mauro Carvalho Chehab added to cc.

This patch probably solves the issue:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3D84b14f181a36eea6591779156ef356f8d198bbfd

The patch were already applied upstream. I've already asked the reporte=
r to test it, via BZ.

Cheers,
Mauro
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
