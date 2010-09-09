From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Thu, 9 Sep 2010 14:50:57 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009091443250.2477@localhost6.localdomain6>
References: <cover.1283504065.git.richard.cochran@omicron.at> <alpine.LFD.2.00.1009091152300.2477@localhost6.localdomain6> <20100909122156.GA2823@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100909122156.GA2823-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2010, Richard Cochran wrote:
> From my point of view, the discussion is going round in circles. There

Sorry for coming late and adding more to the general confusion. :)

> seems to be agreement that supporting PTP hardware clocks is a good
> idea. The objections seem to be about the form of the API. In general,
> there are three avenues.
> 
> 1. character device (like hpet)
> 2. posix clock api
> 3. sysfs
> 
> Or possibly some combination of the three.

I fail to see the requirement for any of those. Either the hardware
clock is suitable as a clocksource for general consumption, then it
should just be used as a clock source. If it's not - e.g. because it's
too slow to access - then it just should serve as a reference in the
NTP style and steer the timekeeping into sync.

As I said in the other reply, I know that you want a global
synchronized clock aside of CLOCK_REALTIME, but that's an easy to
solve problem.

See my other reply for details.

Thanks,

	tglx
