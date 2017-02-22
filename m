From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 20:02:07 -0800
Message-ID: <CALx6S36TNb38pg67_0kymYPpw-BO0DNHQkqa_AGPEZ-RHXaPgw@mail.gmail.com>
References: <CALx6S358XOdPXjHUNUdnrsK-qmDVkmZXWacy1OPBJudVz31OCw@mail.gmail.com>
 <20170221182341.4b2dd0c8@cakuba.netronome.com> <CALx6S36bujuFmDkvG8V5cuigbeNpJX-nprL1_1Ub+m4AiV3Lqw@mail.gmail.com>
 <20170221.223457.625029624566323414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Kicinski <kubakici@wp.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34611 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752218AbdBVECJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 23:02:09 -0500
Received: by mail-qk0-f170.google.com with SMTP id s186so141343793qkb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 20:02:08 -0800 (PST)
In-Reply-To: <20170221.223457.625029624566323414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 7:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 21 Feb 2017 18:54:53 -0800
>
>> It is part of the direction to take XDP beyond the first use case of
>> BPF and leverage the high performance processing model in a much
>> broader context.
>
> And I've stated repeatedly that it's too early to be looking
> that far into the future.
>
> Look Tom, if all you want to do is create infrastructure so that
> you can very easily slither XDP for modules in somewhere, please
> just stop now.  Right now I am completely not interested in even
> entertaining patches which facilitate that.
>
> If instead, you are genuinely interested in making the process of
> writing XDP support for drivers easier, that extremely useful right
> now so please just stick to that specific focus.
>
> I really see no other use case for the XDP hook abstraction other
> than to support XDP module support, which I've said is in no way
> proven to be necessary.
>
> We don't even know what eBPF XDP itself is fully capable of yet,
> so please stop reaching like this.
>

I took out the parts about allowing non-BPF hooks in the patchset as
you requested.I believe code that is cleaner than what is currently
there, and the fact that the API is extensible to allow other uses is
a hallmark of good design.

Tom
