From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 22:25:56 +0200
Message-ID: <20160920202556.GA6713@localhost.localdomain>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 03:56:38PM -0400, Nicolas Pitre wrote:
> - Add a warning for the case where PTP clock subsystem is modular and a
>   driver providing a clock is built-in rather than silently ignoring it.
>   Suggested by Jiri Benc.

So I am really not happy with this.  Here is a common embedded
workflow, at least for me:

1. take some given Kconfig and get it running on the target.

2. for the given HW, change the modules into built-ins, and forget
   module loading

After this series, if I don't pay enough attention to dmesg, then I
have lost functionality that I had in step #1.  That sucks, and it has
nothing to do with the tinification option at all.  It will bite even
if I have no knowledge of it.  That isn't acceptable to me.

Thanks,
Richard
