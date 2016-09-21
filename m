From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Wed, 21 Sep 2016 12:27:16 +0200
Message-ID: <20160921122716.0f609423@griffin>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
        <20160920202556.GA6713@localhost.localdomain>
        <20160920204556.GA7555@localhost.localdomain>
        <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr>
        <alpine.DEB.2.20.1609202300140.5476@nanos>
        <alpine.LFD.2.20.1609201833010.9311@knanqh.ubzr>
        <20160921083851.GA27145@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921083851.GA27145@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Sep 2016 10:38:52 +0200, Richard Cochran wrote:
> Embedded people like to optimize their systems.  One pattern I have
> more than once is that a multihomed design designates a special PTP
> interface, often with a different HW than the other ports.  PTP
> support adds extra code into the hot path, and for that reason people
> want to turn it off on interfaces that don't need it.

We really need to find some middle way. It's impossible to support
every little corner case. As is not reasonable to have a single
configuration only kernel.

I think this scenario falls into the little corner case. If you need
PTP, you just enable it. The PTP core will be much larger than the
added code in the individual drivers anyway.

And if there's run time impact on the fast path with time stamping
switched off on an interface, it's a bug that has to be fixed.

 Jiri
