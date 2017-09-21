From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as standalone
Date: Thu, 21 Sep 2017 09:43:02 -0700
Message-ID: <CAPDqMeq69rjzPh8jo-G9gKT26h-br4OrE0yxTJGk97qRgX0K2A@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net> <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net> <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja> <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
 <20170921151253.4udm54dcq7x3ed4q@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andreas Schultz <aschultz@tpip.net>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:44531 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbdIUQnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:43:05 -0400
Received: by mail-wm0-f41.google.com with SMTP id m127so1632395wmm.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 09:43:04 -0700 (PDT)
In-Reply-To: <20170921151253.4udm54dcq7x3ed4q@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 8:12 AM, Harald Welte <laforge@netfilter.org> wrote:
> Hi Tom,
>
> On Wed, Sep 20, 2017 at 05:55:01PM -0700, Tom Herbert wrote:
>> You have the point of view of someone who has a lot of experience
>> dealing with this protocol. Try to imagine if you were some random
>> kernel network programmer with no experience in the area. If they
>> happen to find a one-off bug and want to do the right thing by running
>> a test, you want to make that as easy as possible.
>
> Agreed.  But we're not talking abut fixing a random bug in your patch
> series, but we're talking about adding significant new features - and
> those features need to be tested in real use caes, not just in an
> artificial test setup that holds assumptions that are not true.
>
> To improve performance, or to fix simple bugs that only affect the
> processing of the GTP-U G-PDU, a much more limited and hence
> "unrealistic" test scenario is probably sufficient/acceptable.
>
>> From that perspective, building protocol specific libraries and
>> finding the right cmd line to run is significant hoops (I can attest
>> to this).
>
> I understand your argument.  But then, there is actually quite some
> tools to help you (see further below), as well as the wiki page at
> http://osmocom.org/projects/linux-kernel-gtp-u/wiki/Basic_Testing
>
> Of course, existing tools and existing wiki pages also only document
> existing features of the kernel code :)
>
> Yes, the documentation could be better.  But then, how much more can you
> expect from somebody who's doing this mostly for fun and who - despite
> working in his dayjob on FOSS cellular projects - has no single
> commercial project/context that uses the kernel GTP code.
>
> In any case, working on a specific protocol or technology will require
> that you understand that technology to some extent, including the
> available tools.  There's always a learning curve involved.
>
>> There are other examples in the kernel of systems bigger than GTP that
>> require a whole lot of effort just to run a simple test; you'll notice
>> for those it's rare that best developers ever bother to look at them
>> unless they're making a global change that affects the code. We don't
>> want GTP to take be like that!
>
> I'm all for following your argument.  My point is simply: You cannot
> develop code solely based on mock-ups without any 'realistic' test
> scenarios.  Otherwise you will end up with something that works only in
> your artificial lab setup, and follows all the best practises of the way
> how the Linux kernel traditionally approaches tunneling implementations,
> but it will never work/interop in the real world.
>

> And I'm very strongly opposed to merging code where we have not been
> able to show that it will inter-operate in at least one realistic
> scenario.  This would raise wrong expectations with users and all sorts
> of downstream problems.
>
Harald,

Please see the cover letter for the original GTP kernel patches dated
May 10, 2016. My first question on those was "Is there a timeline for
adding IPv6 support?". To which Pablo replied that there was a
preliminary patch for it that has not been released. That was almost a
year and half ago and we have not heard anything since. If you don't
like my patches or don't think that can be adapted to fully support
the GTP specification, that's fine. But then you need to provide a
viable alternative. We are at the point where a kernel networking
feature that only supports IPv4 when it could support IPv6 must be
considered incomplete.

Thanks,
Tom
