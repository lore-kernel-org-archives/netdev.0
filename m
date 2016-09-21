From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Wed, 21 Sep 2016 10:38:52 +0200
Message-ID: <20160921083851.GA27145@localhost.localdomain>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
 <20160920202556.GA6713@localhost.localdomain>
 <20160920204556.GA7555@localhost.localdomain>
 <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr>
 <alpine.DEB.2.20.1609202300140.5476@nanos>
 <alpine.LFD.2.20.1609201833010.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1609201833010.9311@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 06:47:02PM -0400, Nicolas Pitre wrote:
> IMHO it is much nicer for the poor user configuring the kernel to have a 
> single configuration prompt for PTP support, and then have whatever 
> driver that can provide a PTP clock just do it (or omit it) based on 
> that single prompt.  Prompting for PTP support for each individual 
> ethernet driver is silly.

Embedded people like to optimize their systems.  One pattern I have
more than once is that a multihomed design designates a special PTP
interface, often with a different HW than the other ports.  PTP
support adds extra code into the hot path, and for that reason people
want to turn it off on interfaces that don't need it.

So Thomas' idea is a better solution.  It reduces the tinification in
this area to a careful kernel configuration.  Yes, that is more work
to configure than having one "big red button" to push.  The burden is
on the tinification user to get this right, and that is the right way,
IMHO.  After all, this can be scripted, and such users have to
configure very carefully in any case.

Thanks,
Richard
