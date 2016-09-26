From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Sun, 25 Sep 2016 21:55:37 -0700
Message-ID: <CAM_iQpVap-7Cp-580p7W8F1UF4t9=Ze+TT6SXsNAYieMvNyppg@mail.gmail.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com> <20160923081106.73fb48df@halley>
 <CAM_iQpU+7NDoGGPkkDHA=v5XW5z98GHQhstFg5H=WCyiBzA-eA@mail.gmail.com> <bd2b555f-cba2-b7bc-1fbe-663da288d8a3@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33720 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756557AbcIZEz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 00:55:59 -0400
Received: by mail-io0-f195.google.com with SMTP id r145so10416376ior.0
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 21:55:58 -0700 (PDT)
In-Reply-To: <bd2b555f-cba2-b7bc-1fbe-663da288d8a3@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 25, 2016 at 6:39 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-24 08:07 PM, Cong Wang wrote:
>>
>> On Thu, Sep 22, 2016 at 10:11 PM, Shmulik Ladkani
>
>
>>
>> One problem to use your code for us is that, the RX side of veth
>> is inside containers, not visible to outside, perhaps we need some
>> more parameter to tell the netns before the device name/index?
>> Thoughts?
>>
>
> Intriguing - but this would apply for only veth?

Yes, my case is only about veth.
