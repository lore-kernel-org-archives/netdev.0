From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: remove the leftover cleanup_a()
Date: Thu, 4 Aug 2016 08:29:22 -0700
Message-ID: <CAM_iQpVEA6vJxveDO2j7z1yPdS3Ed90T89Q6nU784inEX0ryvQ@mail.gmail.com>
References: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com>
 <d82351ba-cd1e-d5e1-0faa-94c2bcaf720a@mojatatu.com> <CAM_iQpVONAiDqgUQhWRbTEUkoEQQPiSUHnpo8aQ8KtGiR1zzFg@mail.gmail.com>
 <193309c8-c4d4-4552-69fe-8b971ac76d53@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37623 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758718AbcHDPaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 11:30:06 -0400
Received: by mail-it0-f43.google.com with SMTP id f6so262898552ith.0
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 08:29:46 -0700 (PDT)
In-Reply-To: <193309c8-c4d4-4552-69fe-8b971ac76d53@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2016 at 5:10 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-08-03 11:20 AM, Cong Wang wrote:
>>
>> On Wed, Aug 3, 2016 at 4:36 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>>
>>> Cong,
>>>
>>> Improvement on the basic test as it no longer oopses, but:
>>> here's a test that will oops:
>>
>>
>> Make sure you test this together with the other patch I sent
>> (sorry I didn't number them), the other patch also fixed an oops.
>>
>
> Ok, just included second patch - problem still there.
> Try the testcase i outlined earlier.

I tried it yesterday, and have been working on a patch.
Basically, I need to replace the list with a flex_array
to hold pointers to these actions. I will send it out tomorrow.

Thanks.
