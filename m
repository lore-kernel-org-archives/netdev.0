From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 0/9] net/sched: init failure fixes
Date: Wed, 30 Aug 2017 08:15:37 -0400
Message-ID: <58c39495-8667-d983-94ba-b1a242f56945@mojatatu.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com, Lucas Bates <lucasb@mojatatu.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34999 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751326AbdH3MPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:15:39 -0400
Received: by mail-it0-f65.google.com with SMTP id b76so920047itb.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:15:39 -0700 (PDT)
In-Reply-To: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-30 05:48 AM, Nikolay Aleksandrov wrote:
> Hi all,
> I went over all qdiscs' init, destroy and reset callbacks and found the
> issues fixed in each patch. Mostly they are null pointer dereferences due
> to uninitialized timer (qdisc watchdog) or double frees due to ->destroy
> cleaning up a second time. There's more information in each patch.
> I've tested these by either sending wrong attributes from user-spaces, no
> attributes or by simulating memory alloc failure where applicable. Also
> tried all of the qdiscs as a default qdisc.
> 
> Most of these bugs were present before commit 87b60cfacf9f, I've tried to
> include proper fixes tags in each patch.
> 
> I haven't included individual patch acks in the set, I'd appreciate it if
> you take another look and resend them.
> 


Hi Nik,

For all patches:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Would you please consider adding all the the tests
you used to create the oopses in selftests? It will ensure this
embarassing bugs get caught should they ever happen again.
If you need help ping Lucas on Cc.

cheers,
jamal
