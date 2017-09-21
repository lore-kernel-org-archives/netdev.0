From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Wed, 20 Sep 2017 17:16:52 -0700
Message-ID: <CAPDqMeoKgd8x+KbQG03RHsBPQVDN6Stn6JkAJgf4u=zxeGGaEw@mail.gmail.com>
References: <20170919003904.5124-9-tom@quantonium.net> <20170918.211952.1397675528248642600.davem@davemloft.net>
 <CALx6S36cJEU2LkbNf-d8kUHCPj78bt5Y2Bd_rdvjxJ9epOEqAQ@mail.gmail.com>
 <20170920.124511.922311380432026759.davem@davemloft.net> <CALx6S36zz1CFq75S5-=UK8wtuK-pxaQdWU7tVuRGhtb_Y9QkDg@mail.gmail.com>
 <20170921000437.rg2h6vyxsrbc3bel@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:49277 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdIUAQy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:16:54 -0400
Received: by mail-wm0-f48.google.com with SMTP id e71so11287182wmg.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 17:16:53 -0700 (PDT)
In-Reply-To: <20170921000437.rg2h6vyxsrbc3bel@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 5:04 PM, Harald Welte <laforge@gnumonks.org> wrote:
> Hi Tom,
>
> On Wed, Sep 20, 2017 at 01:40:54PM -0700, Tom Herbert wrote:
>> On Wed, Sep 20, 2017 at 12:45 PM, David Miller <davem@davemloft.net> wrote:
>> > There is a socket associated with the tunnel to do the encapsulation
>> > and it has an address family, right?
>>
>> If fd's are set from userspace for the sockets then we could derive
>> the address family from them. I'll change that. Although, looking at
>> now I am wondering why were passing fds into GTP instead of just
>> having the kernel create the UDP port like is done for other encaps.
>
> because the userspace process has to take care of those bits of GTP-U
> that the kernel doesn't, such as responding to GTP ECHO requests with
> GTP echo responses.  Only the "GTP Message type G-PDU" is handled in the
> kernel, as only those frames contain user plane.  See table 1 of Section
> 7.1 of 3GPP TS 29.060.
>
Okay, thanks for the explanation.

Tom
