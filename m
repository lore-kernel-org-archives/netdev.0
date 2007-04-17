From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [1/2] 2.6.21-rc7: known regressions
Date: Mon, 16 Apr 2007 20:41:19 -0400
Message-ID: <462417AF.50406@pobox.com>
References: <20070416003714.GL3691@stusta.de> <36D9DB17C6DE9E40B059440DB8D95F5202505C7E@orsmsx418.amr.corp.intel.com> <20070417003212.GB22804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hans-Georg Rist <hg.rist@web.de>, perex@suse.cz,
	alsa-devel@alsa-project.org,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Stephen Clark <Stephen.Clark@seclark.us>,
	linux-ide@vger.kernel.org,
	Michal Jaegermann <michal@ellpspace.math.ualberta.ca>,
	lenb@kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Ingo Molnar <mingo@elte.hu>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	Oliver Neukum <oneukum@suse.de>, greg@kroah.com,
	linux-usb-devel@lists.sourceforge.net, CIJOML <cijoml@volny.cz>,
	Markus Rechberger <markus.rechberger@amd.com>,
	v4l-dvb-maintainer@linuxtv.org
To: Dave Jones <davej@redhat.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20070417003212.GB22804@redhat.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> On Mon, Apr 16, 2007 at 05:14:40PM -0700, Brandeburg, Jesse wrote:
>  > Adrian Bunk wrote:
>  > > Subject    : laptops with e1000: lockups
>  > > References :
>  > > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229603 
>  > > Submitter  : Dave Jones <davej@redhat.com>
>  > > Handled-By : Jesse Brandeburg <jesse.brandeburg@intel.com>
>  > > Status     : problem is being debugged
>  > 
>  > this is being actively debugged, here is what we have so far:
>  > o v2.6.20: crashes during boot, unless noacpi and nousb bootparams used
>  > o v2.6.21-rc6: some userspace issue, crashes just after root mount
>  > without init=/bin/bash
>  > o v2.6.2X: serial console in docking station spews goo at all speeds
>  > with console=ttyS0,bbbbn8 . work continues on this, as we don't know if
>  > there are kernel panic messages during the hard lock.
>  > o fedora 7 test kernel 2948: boots okay, have been using this as only
>  > truly working kernel on this machine.
>  > 
>  > one reproduction of the problem was had with scp -l 5000 <file> <remote>
>  > when linked at 100Mb/Full.  Tried probably 20 other times same test with
>  > no repro, ugh.
>  > 
>  > Otherwise, slogging through continues.  We are actively working on this
>  > in case it *is* an e1000 issue.  Right now the repro is so unlikely we
>  > could hardly tell if we fixed it.
> 
> FWIW, I can reproduce this pretty much ondemand, on 100M through
> the ethernet port on a netgear wireless AP.
> A number of our Fedora7 testers are also able to easily reproduce this.
> To isolate e1000, for tomorrows test build I've reverted e1000 to
> the same code that was in 2.6.20.  If that works out without causing
> hangs, I'll try and narrow down further which of the dozen csets
> is responsible.

Also, there are e1000 fixes in -mm.  At the time (rc2? rc3?) I felt it 
was best to get that into -mm for testing, rather than fast-tracking it 
to 2.6.21.

But hey, see if they help.

It's the netdev-2.6.git#e1000-fixes branch, if you are git-ified.  I was 
going to push them first thing 2.6.22.

	Jeff



