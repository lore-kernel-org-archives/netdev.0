From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 09/14] gtp: Allow configuring GTP interface as standalone
Date: Sun, 24 Sep 2017 08:55:49 -0700
Message-ID: <CAPDqMer0R+XoTzYpQoo7rUY3uVcsa6ffk1FHjkG=3xcuhnDgXg@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-10-tom@quantonium.net>
 <a6d1dad0-e922-2913-d4c8-592d403ee1cb@tpip.net> <CALx6S3771X4QUm2mJG=aJJ0f4Tm98NpGA7060vF1P8iuCPgicQ@mail.gmail.com>
 <56e339a8-fa2d-6f8d-a89c-c0f3f242763a@tpip.net> <CAPDqMeq1tLi=NkLyqma2OEHQi-fYEYeTU-8th9WKoZaeWiM0Rw@mail.gmail.com>
 <20170921001313.n2uo56oxmphcvd5g@nataraja> <CAPDqMeox74aEdV5_cr7HJ=kh0-etLdFE-u5=g8OqRzmS8OjOuQ@mail.gmail.com>
 <20170921151253.4udm54dcq7x3ed4q@nataraja> <CAPDqMeq69rjzPh8jo-G9gKT26h-br4OrE0yxTJGk97qRgX0K2A@mail.gmail.com>
 <20170924021626.b37zlwsomlibtnfs@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andreas Schultz <aschultz@tpip.net>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:43058 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752590AbdIXPzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 11:55:52 -0400
Received: by mail-wm0-f53.google.com with SMTP id m72so7647563wmc.0
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 08:55:51 -0700 (PDT)
In-Reply-To: <20170924021626.b37zlwsomlibtnfs@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It's not about "not liking".  I'm very happy about contributions,
> including (of course) yours.  It's about making sure that code we merge
> into the kernel GTP driver will actually be usable to create a
> standards-compliant GTP application or not.
>
Harald,

Do you believe that these patches are not at all on the right track,
that they can't be built upon to get to a standards-compliant
implementation, and that we are going to have to throw all of this and
start from scratch to provide IPv6 support?

> There's no use in merging an IPv6 support patch if already by code
> review it can be shown that it's impossible to create a spec-compliant
> implementation using that patch.  To me, that would be "merging IPv6
> support so we can check off a box on a management form or marketing
> sheet", but not for any practical value.
>

To be clear, these patches are not done because to be a bullet point
on a marketing sheet. IPv6 is becoming _the_ Internet protocol. It
continues to exhibit exponential growth (~20% of Internet, per Google
stats), I believe least two of the largest datacenter operators are
running everything over IPv6, and there are already proposals to start
official deprecation of IPv4. In the mobile space IPv6 is going to be
a critical enabler of IoT and security in technologies like 5G. If we
want Linux to be at the forefront of the next technology wave then we
need to focus on IPv6 now! We should be far past the days of vendors
only providing IPv4 in the kernel support because "that's what our
customers use" and they'll get to IPv6 support at their leisure. IMO,
davem has every right to unilaterally NAK patches that only support
IPv4 or only test IPv4 with not even a path or timeline for IPv6
support.

Thanks,
Tom
