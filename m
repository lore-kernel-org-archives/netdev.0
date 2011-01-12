From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 12 Jan 2011 12:55:17 -0800
Message-ID: <1294865717.7696.17.camel@work-vm>
References: <cover.1293820862.git.richard.cochran@omicron.at>
	 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
	 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
	 <20110108175028.GA22308@riccoc20.at.omicron.at>
	 <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
	 <1294678145.3068.6.camel@work-vm>
	 <AANLkTikdg4Pb5c4wcCU3d3Eku=mpiW_TEkBz0A2VPdVp@mail.gmail.com>
	 <1294693597.3068.12.camel@work-vm>
	 <AANLkTik+2udoJ6JyZMhkd1yhr2W9hSWO_vD_zdm+BoOG@mail.gmail.com>
	 <1294779309.3441.66.camel@work-vm>
	 <AANLkTikYuYwb4BLsU3BF_=d9fAdcfb0AC2itDBeyFsNq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikYuYwb4BLsU3BF_=d9fAdcfb0AC2itDBeyFsNq-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-13 at 05:39 +0900, Kuwahara,T. wrote:
> On Wed, Jan 12, 2011 at 5:55 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > So the kernel handles leap second insertion via a timer. Thus at the end
> > of 23:59:59, it will inject a leapsecond by setting the time back by one
> > second (back to 23:59:59) and setting the TIME_OOP flag.
> >
> > This timer is an absolute timer, so if someone moves the clock forward
> > across the 23:59:59 boundary, the adjustment will still be made.
> >
> > The patch is not broken, nor useless.
> 
> It takes into account only one upcoming leap second, but ignores all
> the others.  That's not sufficient for arbitrary adjustments.

If an application wants to manage the full historical table of
leapseconds and compensate appropriately, then that's fine. The
interface proposed still functions in a reasonable manner.

Again, I agree that leapseconds are annoying to deal with. It would be
great if time() was defined as TAI time instead of UTC. I'm actually
hoping to provide a CLOCK_TAI clockid someday.

thanks
-john
