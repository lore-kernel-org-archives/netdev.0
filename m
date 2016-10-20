From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 3/4] ptp_clock: allow for it to be optional
Date: Thu, 20 Oct 2016 12:44:34 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201241450.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org> <20161020140601.GC2238@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:33225 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932711AbcJTQog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 12:44:36 -0400
Received: by mail-qt0-f170.google.com with SMTP id s49so61940865qta.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 09:44:36 -0700 (PDT)
In-Reply-To: <20161020140601.GC2238@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Oct 2016, Richard Cochran wrote:

> On Wed, Oct 19, 2016 at 07:42:52PM -0400, Nicolas Pitre wrote:
> > +static inline void ptp_clock_event(struct ptp_clock *ptp,
> > +				   struct ptp_clock_event *event)
> > +{ (void)event; }
> 
> Just out of curiosity, why do you need that cast?

It's redundant and now gone.  Probably a remnant from the initial test 
code that used macros.

Thanks.


Nicolas
