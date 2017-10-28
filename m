From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH v7 net-next 00/13] gtp: Additional feature support - Part I
Date: Sat, 28 Oct 2017 09:16:01 -0700
Message-ID: <CAPDqMer558X27F6F0HqrWVPyAWmTZaLuJ-NmRXP7i4Z-iycfxw@mail.gmail.com>
References: <20171028000937.2631-1-tom@quantonium.net> <20171028080940.dvtzn2cg2rrk6f6t@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Andreas Schultz <aschultz@tpip.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit LastName <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:43738 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdJ1QQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 12:16:03 -0400
Received: by mail-wm0-f54.google.com with SMTP id m72so5774429wmc.0
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 09:16:02 -0700 (PDT)
In-Reply-To: <20171028080940.dvtzn2cg2rrk6f6t@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 28, 2017 at 1:09 AM, Harald Welte <laforge@gnumonks.org> wrote:
> Hi Tom,
>
> my apologies for only getting back to reviews now, after return from
> holidays I was too overloaded with plenty of other tasks.
>
> On Fri, Oct 27, 2017 at 05:09:24PM -0700, Tom Herbert wrote:
>>   - Experimental IPv6 support
>
> As far as I can tell, my previous comments/concerns regarding an IPv6
> support that is in clear violation of how it is specified is not
> acceptable to me, sorry.
>
> The question is - as illustrated quite verbosely before - not one
> of missing certain bits, but it is simply *different* from what
> the protocol specification says.
>
> This makes absolutely no sense to me.  All it will do, is it will raise
> the impression that IPv6 is supported in a spec-compliant way.
> Furthermore, it will mean that once somebody does convert this into
> proper IPv6 support later, they will break the existing use cases of
> the non-compliant implementation that you're adding in this patch
> series.
>
Harald,

Here is what the Kconfig for the EXPERIMENTAL option says:

"This is an experimental implementation that allows encapsulating IPv6
over GTP and using GTP over IPv6 for testing and development purposes.
This is not a standards conformant implementation for IPv6 and GTP.
More work is needed to reach that level."

I don't see any ambiguity here about it not being standards complete.
Nor is there any ambiguity about the its purpose to enable further
development and the fact that more work is needed.

This a foundation for an IPv6 datapath and is sufficient to do
benchmarking and performance to determine the prospects of replacing
proprietary HW with commodity servers running Linux kernel. This is a
forward step to get IPv6 into GTP, and frankly the _only_ code that
has been proposed. There is no reason why someone can't build upon
this to make a first rate conformant implementation.

In any case, I've invested as much time in this as I can for now. I'll
leave it up to DaveM to decide if we wants to take all, none, or some
subset of these patches.

Tom
