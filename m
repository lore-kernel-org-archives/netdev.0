From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v7 net-next 00/13] gtp: Additional feature support - Part I
Date: Sat, 28 Oct 2017 11:37:51 -0700
Message-ID: <CALx6S35R5hK8DMndXRcTHmapavdCFs5YDtdbca3yTznagNXqig@mail.gmail.com>
References: <20171028000937.2631-1-tom@quantonium.net> <20171028080940.dvtzn2cg2rrk6f6t@nataraja>
 <CAPDqMer558X27F6F0HqrWVPyAWmTZaLuJ-NmRXP7i4Z-iycfxw@mail.gmail.com> <20171028164759.5nm7dfpsdqpxewt6@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        "David S . Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Andreas Schultz <aschultz@tpip.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit LastName <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:53847 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdJ1Shw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 14:37:52 -0400
Received: by mail-qt0-f180.google.com with SMTP id n61so12045359qte.10
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 11:37:52 -0700 (PDT)
In-Reply-To: <20171028164759.5nm7dfpsdqpxewt6@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 28, 2017 at 9:47 AM, Harald Welte <laforge@gnumonks.org> wrote:
> Hi Tom,
>
> On Sat, Oct 28, 2017 at 09:16:01AM -0700, Tom Herbert wrote:
>> Here is what the Kconfig for the EXPERIMENTAL option says:
>>
>> "This is an experimental implementation that allows encapsulating IPv6
>> over GTP and using GTP over IPv6 for testing and development purposes.
>> This is not a standards conformant implementation for IPv6 and GTP.
>> More work is needed to reach that level."
>>
>> I don't see any ambiguity here about it not being standards complete.
>> Nor is there any ambiguity about the its purpose to enable further
>> development and the fact that more work is needed.
>
> As stated repeatedly: I have no issue with an *incomplete* implementation,
> but I have a problem with an *incompatible* one that takes left turns
> where the spec takes right turns.
>
> An *incomplete* implementation could still interoperate with other
> implementations but is e.g. missing some optional bits.  It can later
> extended with those missing bits and wills stay compatible to users of
> the incomplete as well as to any later complete implementation.
>
> An *incompatible* implementation is what I have issues with.
>
>> This a foundation for an IPv6 datapath and is sufficient to do
>> benchmarking and performance to determine the prospects of replacing
>> proprietary HW with commodity servers running Linux kernel.
>
> I completely agree with that.
>
>> This is a forward step to get IPv6 into GTP, and frankly the _only_ code that
>> has been proposed. There is no reason why someone can't build upon
>> this to make a first rate conformant implementation.
>
> I also agree with this.  However, I don't think it makes sense to have it in
> the kernel given it implements something that's actually not GTP as per
> the relevant specs.  No matter how many disclaimers you put at it,
> people will still assume it's GTP if it's called GTP.  And if it's only
> useful for benchmarking the poential of a later proper IPv6
> implementation, I don't think it should go in.
>
>> In any case, I've invested as much time in this as I can for now. I'll
>> leave it up to DaveM to decide if we wants to take all, none, or some
>> subset of these patches.
>
> Thanks.  As indicated, I'm planning some testing later this weekend on
> the non-IPv6 patches, and am happy to add my Acked-by and/or re-submit
> those to Dave after that.
>
> For sure, the kernel networking maintainer can merge any patches,
> including the proposed IPv6 patches as-is, and I will accept that.  But
> my vote as the original author and co-maintainer of the kernel GTP code
> goes politely and respectfully against that - as I have made quite clear
> by now.
>
It's been more than a year since the GTP patches went in and I asked
about a IPv6 support-- we haven't heard a peep since then until I
posted these patches. IMO, no IPv6 support for something that could
support it is a _major_ bug-- we are well past the where it's
acceptable to put support in for IPv4 because the "customer uses it"
and "we'll get around to IPv6 later". Customers are using IPv6!
Failure to support it is doing nothing more than holding the protocol
back as well as the kernel, In mobile this especially true, IPv6 is
going to eclipse IPv4. We need GTP kernel to support IPv6!

So, if you don't like these patches and don't think it's the right
direction, that's fine, but as maintainer then please tell us the plan
and timeline to get IPv6 supported in GTP.

Tom


> Thanks + Regards,
>         Harald
>
> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
