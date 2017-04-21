From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 12:12:17 -0400 (EDT)
Message-ID: <20170421.121217.1268145592512455181.davem@davemloft.net>
References: <20170421.113800.1367091481085913667.davem@davemloft.net>
        <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
        <758ff636-365f-6180-9353-69da5d339a3a@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162274AbdDURHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:07:32 -0400
In-Reply-To: <758ff636-365f-6180-9353-69da5d339a3a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 21 Apr 2017 12:01:07 -0400

> On 17-04-21 11:55 AM, Jamal Hadi Salim wrote:
>> On 17-04-21 11:38 AM, David Miller wrote:
> 
>>> If a user says "enable X" and it just gets simply ignored by older
>>> kernels, that can't work properly.  What if "enable X" is something
>>> like "turn on encryption"?  Are you OK with the user getting no
>>> feedback that their stuff is not going to be encrypted?
>>>
>>
>> For this specific use case:
>> Dont they need a newer kernel which supports "enable encryption"?
> 
> Also: What happens to this user space app when it encounters an
> older kernel?
> 
> Using rejection as a capability discovery wont work I think.

Yes for existing attributes we are stuck in the mud because of how
we've handled things in the past.  I'm not saying we should change
behavior for existing attributes.

I'm talking about any newly added attribute from here on out, and
that we need to require checks for them.

Thanks.
