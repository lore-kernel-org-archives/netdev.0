From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Wed, 20 Sep 2017 13:40:54 -0700
Message-ID: <CALx6S36zz1CFq75S5-=UK8wtuK-pxaQdWU7tVuRGhtb_Y9QkDg@mail.gmail.com>
References: <20170919003904.5124-9-tom@quantonium.net> <20170918.211952.1397675528248642600.davem@davemloft.net>
 <CALx6S36cJEU2LkbNf-d8kUHCPj78bt5Y2Bd_rdvjxJ9epOEqAQ@mail.gmail.com> <20170920.124511.922311380432026759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:54713 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdITUk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 16:40:56 -0400
Received: by mail-qk0-f182.google.com with SMTP id d70so3942412qkc.11
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 13:40:55 -0700 (PDT)
In-Reply-To: <20170920.124511.922311380432026759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 12:45 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 20 Sep 2017 11:03:52 -0700
>
>> On Mon, Sep 18, 2017 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Tom Herbert <tom@quantonium.net>
>>> Date: Mon, 18 Sep 2017 17:38:58 -0700
>>>
>>>> Allow peers to be specified by IPv6 addresses.
>>>>
>>>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>>>
>>> Hmmm, can you just check the socket family or something like that?
>>
>> I'm not sure what code you're referring to.
>
> There is a socket associated with the tunnel to do the encapsulation
> and it has an address family, right?

If fd's are set from userspace for the sockets then we could derive
the address family from them. I'll change that. Although, looking at
now I am wondering why were passing fds into GTP instead of just
having the kernel create the UDP port like is done for other encaps.

Tom
