From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 16:52:44 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1609201634550.9311@knanqh.ubzr>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org> <20160920202556.GA6713@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920202556.GA6713@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2016, Richard Cochran wrote:

> On Tue, Sep 20, 2016 at 03:56:38PM -0400, Nicolas Pitre wrote:
> > - Add a warning for the case where PTP clock subsystem is modular and a
> >   driver providing a clock is built-in rather than silently ignoring it.
> >   Suggested by Jiri Benc.
> 
> So I am really not happy with this.  Here is a common embedded
> workflow, at least for me:
> 
> 1. take some given Kconfig and get it running on the target.
> 
> 2. for the given HW, change the modules into built-ins, and forget
>    module loading
> 
> After this series, if I don't pay enough attention to dmesg, then I
> have lost functionality that I had in step #1.

Would that given config from #1 typically have CONFIG_EXPERT actually 
set?

Ultimately, do you know a way to restrict a tristate to y or n? A 
tristate can be limited to m or n with "depends on m" but it doesn't 
appear to be possible to exclude m with a promotion to y.


Nicolas
