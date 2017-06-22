From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] udp: ipv6: reset daddr and dport in sk if connect() fails
Date: Thu, 22 Jun 2017 11:00:42 -0700
Message-ID: <CAEA6p_DxFKuiW4+tGzFNnB7qhcBiNEAk0LTLqEV=OppHYKaeHw@mail.gmail.com>
References: <20170621213631.145600-1-tracywwnj@gmail.com> <20170622.132500.2137901400094983652.davem@davemloft.net>
 <CAEA6p_Ba+b3s-H-kM1SCu5f2T413EF0Z8sOP-tfbDDJm3YotVw@mail.gmail.com> <20170622.135408.293309819386939085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: =?UTF-8?B?546L6JSa?= <tracywwnj@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        subashab@codeaurora.org,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:35475 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdFVSAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 14:00:44 -0400
Received: by mail-ua0-f182.google.com with SMTP id j53so23295328uaa.2
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 11:00:44 -0700 (PDT)
In-Reply-To: <20170622.135408.293309819386939085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 10:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Wei Wang <weiwan@google.com>
> Date: Thu, 22 Jun 2017 10:49:24 -0700
>
>> On Thu, Jun 22, 2017 at 10:25 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Wei Wang <tracywwnj@gmail.com>
>>> Date: Wed, 21 Jun 2017 14:36:31 -0700
>>>
>>>> +             memset(&sk->sk_v6_daddr, 0 sizeof(sk->sk_v6_daddr);
>>>
>>> Tell me how that compiles.
>>
>> Really sorry about that. I ported over the change manually from
>> another branch and made the stupid mistake...
>> Will send out v2 shortly.
>
> Misporting the change isn't stupid.
>
> Not build and functionally testing your change is.

Yes. Agree...
I did the testing on the other branch but did not do it again after
porting the change over.
Will definitely remember to do it next time. Really sorry about it...
