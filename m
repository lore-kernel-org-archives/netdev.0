From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 20:09:16 +0100
Message-ID: <201102032009.17100.rjw@sisk.pl>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera> <AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com> <s5haaid3xos.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Carlos R. Mafra" <crmafra2@gmail.com>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>,
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
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <s5haaid3xos.wl%tiwai@suse.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, February 03, 2011, Takashi Iwai wrote:
> At Thu, 3 Feb 2011 07:42:05 -0800,
> Linus Torvalds wrote:
> > 
> > On Thu, Feb 3, 2011 at 3:23 AM, Carlos R. Mafra <crmafra2@gmail.com> wrote:
> > > On Thu  3.Feb'11 at  1:03:41 +0100, Rafael J. Wysocki wrote:
> > >>
> > >> If you know of any other unresolved post-2.6.36 regressions, please let us know
> > >> either and we'll add them to the list.  Also, please let us know if any
> > >> of the entries below are invalid.
> > >
> > > I'm sorry if I'm overlooking something, but as far as I can see the regression
> > > reported here:
> > >
> > > https://lkml.org/lkml/2011/1/24/457
> > >
> > > is not in the list (update on that report: reverting that commit on top of
> > > 2.6.37 fixes the issue).
> > 
> > Ok, added Keith and Dave to the cc, since they are the signers of that commit.
> > 
> > > After some time, I also ended up finding an earlier report in the kernel bugzilla
> > > which I think is the same regression (it was bisected to the same commit):
> > >
> > > https://bugzilla.kernel.org/show_bug.cgi?id=24982
> > >
> > > but I do not see it in the list either, even though it's marked as a
> > > regression in the bugzilla.
> > >
> > > The issue was also present in 2.6.38-rc2 last time I tested.
> > 
> > Just to confirm, can you also check -rc3? I'm pretty sure nothing has
> > changed, but there were a few drm patches after -rc2, so it's alsways
> > good to double-check.
> 
> The problem I reported in the bugzilla above is still present in
> 2.6.38-rc3.  I'm pretty sure that's the same issue as Carlos' case.

I added https://bugzilla.kernel.org/show_bug.cgi?id=24982 to the list of
post-2.6.36 regressions for further tracking.

Thanks,
Rafael
