From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Tue, 20 Sep 2016 16:58:40 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1609201655200.9311@knanqh.ubzr>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org> <20160920202556.GA6713@localhost.localdomain> <20160920204556.GA7555@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34074 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754314AbcITU6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 16:58:44 -0400
Received: by mail-qk0-f177.google.com with SMTP id n185so27943893qke.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 13:58:42 -0700 (PDT)
In-Reply-To: <20160920204556.GA7555@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016, Richard Cochran wrote:

> On Tue, Sep 20, 2016 at 10:25:56PM +0200, Richard Cochran wrote:
> > After this series, if I don't pay enough attention to dmesg, then I
> > have lost functionality that I had in step #1.  That sucks, and it has
> > nothing to do with the tinification option at all.  It will bite even
> > if I have no knowledge of it.  That isn't acceptable to me.
> 
> Can't you leave all the "select PTP_1588_CLOCK" alone and simply add
> 
> #ifdef CONFIG_POSIX_TIMERS
> 	// global declarations
> #else
> 	// static inlines
> #endif
> 
> to ptp_clock_kernel.h, and then sandwich ptp_clock.c in
> #ifdef CONFIG_POSIX_TIMERS ... #endif ?

Sure I could... but I'm sure I'll be flamed by others for making things 
even more obscure and hackish than they are right now.

Oh well...  Let's go fix the Kconfig parser then.


Nicolas
