From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sun, 15 Mar 2009 10:58:16 +0800
Message-ID: <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <MiincthRUSI.A.eKC.F4BvJB@chimera>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 15, 2009 at 3:01 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
12414
> Subject =A0 =A0 =A0 =A0 : iwl4965 cannot use "ap auto" on latest 2.6.=
28/29?
> Submitter =A0 =A0 =A0 : Jeff Chua <jeff.chua.linux@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2009-01-05 4:13 (69 days old)
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D123112=
882127823&w=3D4

Still not working in linux-2.6.29-rc8. Broken after the commit below.
There were many changes to wireless after this commit, and simply
reverting this commit will break compiling.

Jeff.



commit 41bb73eeac5ff5fb217257ba33b654747b3abf11
Author: Johannes Berg <johannes@sipsolutions.net>
Date:   Wed Oct 29 01:09:37 2008 +0100

    mac80211: remove SSID driver code
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
