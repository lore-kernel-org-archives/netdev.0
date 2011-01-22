From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH V9 08/13] posix clocks: cleanup the CLOCK_DISPTACH
 macro
Date: Sat, 22 Jan 2011 13:42:39 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101221342100.31804@localhost6.localdomain6>
References: <cover.1294917347.git.richard.cochran@omicron.at> <90b2beef441615d01c93fcad029c44af4e505c5f.1294917348.git.richard.cochran@omicron.at> <alpine.LFD.2.00.1101131745400.2678@localhost6.localdomain6> <20110122123840.GA30830@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110122123840.GA30830-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 22 Jan 2011, Richard Cochran wrote:

> On Thu, Jan 13, 2011 at 06:03:24PM +0100, Thomas Gleixner wrote:
> > On Thu, 13 Jan 2011, Richard Cochran wrote:
> > >  int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
> > >  int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
> > > -int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
> > > +int posix_cpu_clock_set(const clockid_t which_clock, struct timespec *ts);
> > 
> > Shouldn't we change the clock_set function to have *ts const in all places ?
> 
> The common_clock_set function calls:
> 
>     do_sys_settimeofday
>         security_settime
>             cap_settime
>     do_settimeofday
> 
> so all their signatures must also change.
> 
> Should I add that into my patch set?

Yes please as a separate patch.

Thanks,

	tglx
