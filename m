From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 17:43:31 +0200
Message-ID: <200705281743.32134.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <200705281714.25841.mb@bu3sch.de> <1180366371.4952.5.camel@chaos>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1180366371.4952.5.camel@chaos>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 28 May 2007 17:32:51 Thomas Gleixner wrote:
> On Mon, 2007-05-28 at 17:14 +0200, Michael Buesch wrote:
> > > The -oldconfig1 is the kernel that had no problems and the other shows the b44 
> > > problem. So if High Resolution Timer Support is disabled everything works 
> > > fine and if I enable it the problems do appear again.
> > > 
> > > I didn't test this on my 2.6.22-rc3 kernel yet, but I guess disabling High 
> > > Resolution Timer Support will also solve the problem there.
> > > 
> > > The older kernels I tried also work perfectly fine and they didn't have the 
> > > High Resolution Timer Support yet.
> > 
> > So, that's interesting, indeed.
> > Any idea what's going on, someone? Thomas?
> 
> Not off the top of my head.
> 
> Maximilian, does the kernel work otherwise (I mean aside of the b44
> driver) ? 
> 
> Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try the
> following combinations on the kernel command line:
> 
> 1) highres=off nohz=off (should be the same as your working config)
> 2) highres=off
> 3) nohz=off
> 
> Michael, is anything in the b44 driver timer driven ?

NAPI perhaps. I don't know. Steve may know.

The only timer in b44 is to update stats every second. I doubt
that this can cause such an issue. It's not involved in transmission.

-- 
Greetings Michael.
