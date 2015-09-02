From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Tue, 1 Sep 2015 23:26:32 -0700
Message-ID: <CAM_iQpX3UQuft9yrUEDo7ZmHhvM4CQj8UB=poPnz4punyvc8jQ@mail.gmail.com>
References: <20150828.162037.473306692661391284.davem@davemloft.net>
	<55E3546B.8000605@mojatatu.com>
	<CAM_iQpVS2qzPeJNfNY11XP-b3bJH1BAU2aa2H3hLzu+F-zKAOw@mail.gmail.com>
	<20150901.231913.1408311787626700854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36691 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbbIBG0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 02:26:33 -0400
Received: by oibi136 with SMTP id i136so164424oib.3
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 23:26:32 -0700 (PDT)
In-Reply-To: <20150901.231913.1408311787626700854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 1, 2015 at 11:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 1 Sep 2015 23:05:45 -0700
>
>> On Sun, Aug 30, 2015 at 12:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>> On 08/28/15 19:20, David Miller wrote:
>>>
>>>> But HTB definitely should be allowed.
>>>
>>>
>>> Problem with most non-work conserving schedulers is what the meaning
>>> of default resources means; example, for HTB:
>>> What is the default bandwidth you allocate to a class of users?
>>
>> Exactly, that is why it has to need at least one parameter for bandwidth,
>> while default qdisc requires no parameter.
>
> Ok I'm convinced.

Ok, I will update the changelog to clarify this and resend.

Thanks.
