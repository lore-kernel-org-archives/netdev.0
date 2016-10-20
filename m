From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 4/4] posix-timers: make it configurable
Date: Thu, 20 Oct 2016 12:41:27 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201234570.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-5-git-send-email-nicolas.pitre@linaro.org> <20161020140213.GB2238@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20161020140213.GB2238@netboy>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Oct 2016, Richard Cochran wrote:

> On Wed, Oct 19, 2016 at 07:42:53PM -0400, Nicolas Pitre wrote:
> > +config POSIX_TIMERS
> > +	bool "Posix Clocks & timers" if EXPERT
> > +	default y
> > +	help
> > +	  This includes native support for POSIX timers to the kernel.
> > +	  Most embedded systems may have no use for them and therefore they
> 
> This sentence doesn't make sense.  How about:
> 
> 	  Some embedded systems have no use for them ...

As you wish.

Turns out that my own use of Fedora currently makes no use of them 
either.


Nicolas
