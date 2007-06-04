From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 04 Jun 2007 08:39:48 +0200
Message-ID: <1180939188.4404.5.camel@chaos>
References: <20070525172431.60affaca@freepuppy>
	 <200705281944.05030.maxi@daemonizer.de> <1180380230.3657.3.camel@chaos>
	 <200706031826.06891.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200706031826.06891.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-06-03 at 18:26 +0200, Maximilian Engelhardt wrote:
> > Is there any other strange behavior of the high res enabled kernel than
> > the b44 problem ?
> 
> I didn't notice anything in the past (as I wrote). But today I did some tests 
> for an updated version of the p54 mac80211 wlan driver and I noticed exactly 
> the same problem:
> 
> when booting with highres=off everything is fine.
> But when I boot an highres enabled kernel and I do the iperf-test with the p54 
> driver, my systems becomes unresponsive during the test. It seems to be 
> exactly the same problem I have with the b44 driver.
> So this might not be a bug in the b44 code but a bug somewhere in the linux 
> networking code.
> 
> I did the test with an 2.6.22-rc3-git4 kernel and the p54 driver built 
> external as module. 

Can you look at iperf to figure out, whether it does some weird timer
stuff (high frequency interval timer or such) ? Either check the code or
strace it.

	tglx
