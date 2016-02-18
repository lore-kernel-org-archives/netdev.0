From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Thu, 18 Feb 2016 07:26:13 -0500
Message-ID: <56C5B865.5050608@mojatatu.com>
References: <1455709055-30881-1-git-send-email-jhs@emojatatu.com>
 <1455709055-30881-2-git-send-email-jhs@emojatatu.com>
 <CAM_iQpX+b7F87gx4PcEhs0xFA6KtUssJAQo7+Jo9g9kLcOfB6w@mail.gmail.com>
 <56C5B0AB.8040802@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38690 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030276AbcBRM0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 07:26:14 -0500
Received: by mail-ig0-f182.google.com with SMTP id y8so11277044igp.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 04:26:14 -0800 (PST)
In-Reply-To: <56C5B0AB.8040802@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-18 06:53 AM, Daniel Borkmann wrote:
> On 02/17/2016 06:27 PM, Cong Wang wrote:

>>>          const struct tcf_proto *old_tp = tp;
>>>          int limit = 0;
>>> -
>>
>> Why remove this empty line? I think it is still useful. :)
>>
>> Also your patch should be targeted to -net instead of -net-next, since it
>> fixes a bug.
>
> Yeah, good point. That should go to -net (minus the unrelated white
> space change).
>


One patch coming right up boys;->

cheers,
jamal
