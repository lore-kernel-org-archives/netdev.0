From: "Gary Zambrano" <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Tue, 29 May 2007 06:58:43 -0700
Message-ID: <1180447123.17146.4.camel@dhcp-10-12-136-115.broadcom.com>
References: <20070525172431.60affaca@freepuppy>
 <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
 <200705282255.56490.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Thomas Gleixner" <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Maximilian Engelhardt" <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705282255.56490.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-28 at 13:55 -0700, Maximilian Engelhardt wrote:
> On Monday 28 May 2007, Thomas Gleixner wrote:
> > On Mon, 2007-05-28 at 19:44 +0200, Maximilian Engelhardt wrote:
> > > > Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try the
> > > > following combinations on the kernel command line:
> > > >
> > > > 1) highres=off nohz=off (should be the same as your working config)
> > > > 2) highres=off
> > > > 3) nohz=off
> > >
> > > I tested this with my 2.6.22-rc3 kernel, here are the results:
> > >
> > > without any special boot parameters: problem does appear
> > > highres=off nohz=off: problem does not appear
> > > highres=off: problem does not appear
> > > nohz=off: problem does appear
> >
> > Is there any other strange behavior of the high res enabled kernel than
> > the b44 problem ?
> 
> I didn't notice anything.
> 
> >
> > > I additionally built my 2.6.22-rc2-mm1 kernel without High Resolution
> > > Timer, but the high ping problem is still there.
> >
> > Hmm, that's mysterious. Wild guess is that highres exposes the hidden
> > "feature" in a different way than rc2-mm1 does.
> 
> I think the bug in 2.6.21/22-rc3 is a different one that the one in 
> 2.6.22-rc2-mm1, but that's also only a wild guess :)
> 
> I'll explain this a bit:
> In 2.6.21/22-rc3 is the same b44 driver that has been in the stock kernels for 
> some time. With this driver and High Resolution Timer turned on I get 
> problems using iperf. The problems are that the systems becomes really slow 
> and unresponsive.  Michael Buesch thought this could be an IRQ storm which 
> sounds logical to me. This bug did never happen to me before I startet the 
> iperf test.


Can you please check to see if you notice anything out of the ordinary
using netperf in place of iperf in your high res timer on/off testbed?

Thanks,
Gary
