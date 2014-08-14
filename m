From: Simon Horman <horms@verge.net.au>
Subject: Re: smsc911x_suspend crash (was: Re: [PATCH] ARM: shmobile: r8a7778:
 Add missing call to shmobile_init_late())
Date: Fri, 15 Aug 2014 06:17:13 +0900
Message-ID: <20140814211712.GC2029@verge.net.au>
References: <CAMuHMdV7u-9DQ=TGBYSh2GvQgzQE3EAabXoEGU=3N4XyZ_Dx6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Kevin Hilman <khilman@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43968 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932194AbaHNVRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 17:17:16 -0400
Content-Disposition: inline
In-Reply-To: <CAMuHMdV7u-9DQ=TGBYSh2GvQgzQE3EAabXoEGU=3N4XyZ_Dx6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 14, 2014 at 10:52:30AM +0200, Geert Uytterhoeven wrote:
> Hi Simon,
> 
> (taking this to netdev for the crash in smsc911x_suspend())
> 
> On Thu, Aug 14, 2014 at 8:16 AM, Simon Horman <horms@verge.net.au> wrote:
> > while this may be part of the puzzle my light testing shows
> > that suspend-to-ram does not appear to work with this patch applied.
> 
> Thanks for testing!
> 
> > My procedure is as followw.
> >
> > 1. Apply this patch on top of renesas-devel-v3.16-20140811
> > 2. make bockw_defconfig
> > 3. Select CONFIG_SUSPEND
> > 4. Update r8a7778-bockw.dts to include no_console_suspend in bootargs
> 
> Alternative:
> 
> echo 0 > /sys/module/printk/parameters/console_suspend

Thanks, I didn't know that.

> > 4. Boot and then:
> >
> >    i. echo enabled > /sys/devices/platform/sh-sci.0/tty/ttySC0/power/wakeup
> >    ii. echo mem > /sys/power/wakeup_count
> 
> Uh?
> 
> echo mem > /sys/power/state
> 
> > root@debian:~# echo mem > /sys/power/wakeup_count
> > -bash: echo: write error: Invalid argument
> 
> I guess there's an "echo mem > /sys/power/state" here?

Yes, sorry about that noise. I had some stray commands in my test-run
and edited out the correct one.
