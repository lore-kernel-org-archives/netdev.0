From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 22:45:56 +0200
Message-ID: <20160920204556.GA7555@localhost.localdomain>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
 <20160920202556.GA6713@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160920202556.GA6713@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 10:25:56PM +0200, Richard Cochran wrote:
> After this series, if I don't pay enough attention to dmesg, then I
> have lost functionality that I had in step #1.  That sucks, and it has
> nothing to do with the tinification option at all.  It will bite even
> if I have no knowledge of it.  That isn't acceptable to me.

Can't you leave all the "select PTP_1588_CLOCK" alone and simply add

#ifdef CONFIG_POSIX_TIMERS
	// global declarations
#else
	// static inlines
#endif

to ptp_clock_kernel.h, and then sandwich ptp_clock.c in
#ifdef CONFIG_POSIX_TIMERS ... #endif ?

Thanks,
Richard
