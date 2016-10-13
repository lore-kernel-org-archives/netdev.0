From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Thu, 13 Oct 2016 07:54:52 -0400
Message-ID: <66664527-cd40-453b-7130-7447e4c6083d@mojatatu.com>
References: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWDwwo+DEi2aytoAnTHWKWeTRiMZqXfvaB7=T9eOnvR-w@mail.gmail.com>
 <1476344769.5650.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34695 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754202AbcJMLzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 07:55:13 -0400
Received: by mail-io0-f193.google.com with SMTP id i202so4744572ioi.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 04:54:54 -0700 (PDT)
In-Reply-To: <1476344769.5650.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-13 03:46 AM, Eric Dumazet wrote:
> On Wed, 2016-10-12 at 09:36 -0700, Cong Wang wrote:
>> On Sun, Oct 9, 2016 at 8:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> +       if (unicast)
>>> +               return netlink_unicast(net->rtnl, skb, portid, MSG_DONTWAIT);
>>
>> Nit: rtnl_unicast() is simpler.
>
> I copied code in rtnetlink_send(), I guess we could use rtnl_unicast()
> there as well.

I would toss a coin and if it lands on tail then make the change ;->
(probably in a separate patch).

cheers,
jamal
