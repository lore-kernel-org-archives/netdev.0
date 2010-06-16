From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 16 Jun 2010 14:34:27 -0700
Message-ID: <20100616143427.a0323701.akpm@linux-foundation.org>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
	<AANLkTiksbL1qHg7Q0A-6TbX0uUrxra4jctUoIGVk5vnE@mail.gmail.com>
	<201006091122.35304.rjw@sisk.pl>
	<20100616134231.23ff30da.akpm@linux-foundation.org>
	<AANLkTil-X5IMZMer7fHVPOMalsTJNliv-gMimzKmJ3Od@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sedat Dilek <sedat.dilek@googlemail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>, dmonakhov@openvz.org
To: sedat.dilek@gmail.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <AANLkTil-X5IMZMer7fHVPOMalsTJNliv-gMimzKmJ3Od@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2010 23:00:37 +0200
Sedat Dilek <sedat.dilek@googlemail.com> wrote:

> On Wed, Jun 16, 2010 at 10:42 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 9 Jun 2010 11:22:35 +0200
> > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> >
> >> On Wednesday 09 June 2010, Sedat Dilek wrote:
> >> > The patch from [1] is still missing.
> >> >
> >> > __ __"cpufreq-call-nr_iowait_cpu-with-disabled-preemption.patch" from
> >> > Dmitry Monakhoc
> >> >
> >> > Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
> >> > Tested-by Maciej Rutecki <maciej.rutecki@gmail.com>
> >> >
> >> > I have already reported this issue on LKML [2] and cpufreq ML [3].
> >> >
> >> > - Sedat -
> >> >
> >> > [1] http://www.spinics.net/lists/cpufreq/msg01631.html
> >> > [2] http://lkml.org/lkml/2010/5/31/77
> >> > [3] http://www.spinics.net/lists/cpufreq/msg01637.html
> >>
> >> Thanks, added.
> >
> > I just merged a different patch whcih should address this:
>
> How do cpu-freq related stuff find its way into mainline?
> Is there a GIT repository/branch on <git.kernel.org> where you can pull from?
> 

(top-posting repaired.  Please don't)

Usually via the cpufreq git tree, mailing list and maintainer, as
described in ./MAINTAINERS.

But for a patch like this one, I'll just scoot it into mainline unless
Dave happens to grab it before I do that.

