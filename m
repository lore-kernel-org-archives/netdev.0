From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2 5/5] posix-timers: make it configurable
Date: Wed, 26 Oct 2016 09:56:13 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610260941520.14694@knanqh.ubzr>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org> <1477448931-29051-6-git-send-email-nicolas.pitre@linaro.org> <20161026085102.GC11974@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Michal Marek <mmarek@suse.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161026085102.GC11974@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Oct 2016, Richard Cochran wrote:

> On Tue, Oct 25, 2016 at 10:28:51PM -0400, Nicolas Pitre wrote:
> > +config POSIX_TIMERS
> > +	bool "Posix Clocks & timers" if EXPERT
> > +	default y
> > +	help
> > +	  This includes native support for POSIX timers to the kernel.
> > +	  Most embedded systems may have no use for them and therefore they
> > +	  can be configured out to reduce the size of the kernel image.
> 
> Can you please fix this sentence?  It doesn't make any sense.  "Most"
> is making a definite statement of fact, while "may have no use" is
> not.

I'm not a native speaker. I'm afraid I just don't appreciate such 
nuances.

> Either you mean:
> 
>   1. Most embedded systems have no use for them.
> 
>   2. Embedded systems may have no use for them.
> 
> or expressing #2 in other words:
> 
>   3. Many embedded systems have no use for them.
> 
>   4. Some embedded systems have no use for them.
> 
> Take your pick.  (But I doubt #1 is really true, and so I would like
> to see some numbers to back up that claim.)

I used 4 to match the commit message, which incidentally is the result 
of a prior suggestion from you. Sorry for not being consistent then.

As for numbers... I don't have any, but I probably mentioned already 
that I can run a copy of Fedora on top of a kernel with POSIX timers 
disabled and none of the warnings about those disabled syscalls are 
triggered. So if my Fedora usage doesn't need them, we can infer that 
the number of embedded systems also not needing them might tend towards 
a high percentage. But let's be conservative and say "some".

Thanks for your review.


Nicolas
