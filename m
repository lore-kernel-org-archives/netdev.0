From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc
 to inappropriate ones
Date: Tue, 01 Sep 2015 23:19:13 -0700 (PDT)
Message-ID: <20150901.231913.1408311787626700854.davem@davemloft.net>
References: <20150828.162037.473306692661391284.davem@davemloft.net>
	<55E3546B.8000605@mojatatu.com>
	<CAM_iQpVS2qzPeJNfNY11XP-b3bJH1BAU2aa2H3hLzu+F-zKAOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34758 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbbIBGTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 02:19:16 -0400
In-Reply-To: <CAM_iQpVS2qzPeJNfNY11XP-b3bJH1BAU2aa2H3hLzu+F-zKAOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 1 Sep 2015 23:05:45 -0700

> On Sun, Aug 30, 2015 at 12:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 08/28/15 19:20, David Miller wrote:
>>
>>> But HTB definitely should be allowed.
>>
>>
>> Problem with most non-work conserving schedulers is what the meaning
>> of default resources means; example, for HTB:
>> What is the default bandwidth you allocate to a class of users?
> 
> Exactly, that is why it has to need at least one parameter for bandwidth,
> while default qdisc requires no parameter.

Ok I'm convinced.
