From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/9] net/sched: init failure fixes
Date: Wed, 30 Aug 2017 15:26:27 -0700 (PDT)
Message-ID: <20170830.152627.1894578527302246567.davem@davemloft.net>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
        <58c39495-8667-d983-94ba-b1a242f56945@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
        edumazet@google.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com, lucasb@mojatatu.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdH3W03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:26:29 -0400
In-Reply-To: <58c39495-8667-d983-94ba-b1a242f56945@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Wed, 30 Aug 2017 08:15:37 -0400

> On 17-08-30 05:48 AM, Nikolay Aleksandrov wrote:
>> Hi all,
>> I went over all qdiscs' init, destroy and reset callbacks and found
>> the
>> issues fixed in each patch. Mostly they are null pointer dereferences
>> due
>> to uninitialized timer (qdisc watchdog) or double frees due to
>> ->destroy
>> cleaning up a second time. There's more information in each patch.
>> I've tested these by either sending wrong attributes from user-spaces,
>> no
>> attributes or by simulating memory alloc failure where
>> applicable. Also
>> tried all of the qdiscs as a default qdisc.
>> Most of these bugs were present before commit 87b60cfacf9f, I've tried
>> to
>> include proper fixes tags in each patch.
>> I haven't included individual patch acks in the set, I'd appreciate it
>> if
>> you take another look and resend them.
>> 
> 
> 
> Hi Nik,
> 
> For all patches:
> 
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Series applied, thanks Nikolay.
