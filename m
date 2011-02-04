From: Dave Airlie <airlied@gmail.com>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Fri, 4 Feb 2011 11:42:33 +1000
Message-ID: <AANLkTim-1MofNWc_PkmKE3dPWB3Ahe8d8jP_aUD5konx@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
	<AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
	<s5haaid3xos.wl%tiwai@suse.de>
	<201102032009.17100.rjw@sisk.pl>
	<AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
	<AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
	<AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com>
	<AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com>
	<yund3n88v7x.fsf@aiko.keithp.com>
	<AANLkTin-9a5Z3qq4t8UakRvgB1G3_CT2RLKMVaHXvnLr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Keith Packard <keithp@keithp.com>,
	Carlos Mafra <crmafra2@gmail.com>,
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
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <AANLkTin-9a5Z3qq4t8UakRvgB1G3_CT2RLKMVaHXvnLr@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 4, 2011 at 11:11 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Feb 3, 2011 at 5:05 PM, Keith Packard <keithp@keithp.com> wrote:
>>
>> The goal is to make it so that when you *do* set a mode, DPMS gets set
>> to ON (as the monitor will actually be "on" at that point). Here's a
>> patch which does the DPMS_ON precisely when setting a mode.
>
> Ok, patch looks sane, but it does leave me with the "what about the
> 'fb_changed' case?" question. Is that case basically guaranteed to not
> change any existing dpms state?

Yes its inconsistent behaviour but nothing in the fb_changed case will
affect the DPMS
state. I expect we should probably do that so all paths via that
function turn DPMS on,
and it'll be consistent, might be something for 39.

Dave.
