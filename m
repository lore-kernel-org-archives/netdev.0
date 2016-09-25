From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 19:45:15 -0400
Message-ID: <6e7bfffe-c2f3-2878-b501-3586f962adcc@mojatatu.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
 <20160923184030.75124289@halley>
 <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
 <20160925203309.633cf3d5@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36630 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757597AbcIYXpS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 19:45:18 -0400
Received: by mail-io0-f196.google.com with SMTP id z135so10201151ioe.3
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 16:45:18 -0700 (PDT)
In-Reply-To: <20160925203309.633cf3d5@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-25 01:33 PM, Shmulik Ladkani wrote:
> On Sun, 25 Sep 2016 09:05:08 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-09-23 11:40 AM, Shmulik Ladkani wrote:
>>>
>>> [off topic]
>>
>> I think this is still on topic!
>
> Sorry, wasn't too clear on that.
>
> What I meant is that _existing_ "egress redirect" already gets us into
> crazy loops - the veth misconfig being just one example of, but
> many more exist (many device stacking constructs, with lower dev issuing
> an egress-redirect back to the topmost dev).
>

So this is stopped by the xmit_recursion Daniel mentioned, correct?

> Point is, IMO loop detection (whether/how addressed), is orthogonal to
> this series implementing "ingress redirect", and doesn't seem as a
> strict prerequisite to adding the "ingress redirect" functionality to
> act_mirred.
>
> We can later address any loop-detection improvements in mirred.
> WDYT?
>

If indeed the xmit_recursion solves the egress->egress problem then I
would suggest we need to address the egress->ingress issue.
BTW: plans to also address ingress->ingress?

cheers,
jamal
