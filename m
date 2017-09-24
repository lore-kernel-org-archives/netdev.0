From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as standalone
Date: Sun, 24 Sep 2017 10:18:53 -0700
Message-ID: <CALx6S344q97n7su_k_RmEWT6LytmEFdek9YMgU=8LdgO3kAPHw@mail.gmail.com>
References: <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net>
 <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net> <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja> <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
 <20170921151253.4udm54dcq7x3ed4q@nataraja> <CAPDqMeq69rjzPh8jo-G9gKT26h-br4OrE0yxTJGk97qRgX0K2A@mail.gmail.com>
 <20170924021626.b37zlwsomlibtnfs@nataraja> <CAPDqMer0R+XoTzYpQoo7rUY3uVcsa6ffk1FHjkG=3xcuhnDgXg@mail.gmail.com>
 <20170924162543.d7syskutxzgvbw23@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Andreas Schultz <aschultz@tpip.net>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:50743 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752550AbdIXRSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 13:18:55 -0400
Received: by mail-qt0-f179.google.com with SMTP id f15so4960433qtf.7
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 10:18:54 -0700 (PDT)
In-Reply-To: <20170924162543.d7syskutxzgvbw23@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm not sure where a "vendor" is involved with the GTP patches so far.  I
> think we have to draw a distinction between what you expect from
> professional, corporate "vendors" with a commercial interest in mind
> (such as supporting their hardware) and what you can expect from people
> doing things in their spare time, out of enthusiasm to finally bring
> some Free Software into the closed world of telecommunications.
>
If it makes you feel any better I am not getting paid for this work either :-)

> The Telecom world should have implemented something like a GTP kernel
> module a decade to 15 years ago.  They could have saved significant
> investments in proprietary hardware by running open source GGSNs with an
> accelerated user plane in the kernel.  Nobody seemed to have an interest
> in that, until today - as you can see from Pablo and me working on this
> in our spare time, whenever we have a couple of spare cycles next to
> many other projects.  You can see from the osmo-gtp-kernel commit log it
> took years of being a ultra-low-priority on-and-off project  to ever get
> to a point where we thought it was worth submitting it mainline.
> Andreas deserves the praise for finally pushing it ahead.
>
I completely agree, and your work is well appreciated! But I don't
believe it is to late to steer the ship away from proprietary
solutions. In fact, given the direction of the rest of the industry
direction, now is our best opportunity to try. That is a major reason
for these patches. We need to bring GTP into the limelight and get a
lot more people thinking about. This might even be the world's most
important tunneling protocol. If nothing else, a discussion like this
is good if it inspires others in the community to start to look at it.

Tom
