From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v3 5/5] net_sched: convert tcf_exts from list to
 pointer array
Date: Sun, 14 Aug 2016 07:00:11 -0400
Message-ID: <5d5bf6a8-f8e1-e95e-e6ab-fe21fb5d2220@mojatatu.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
 <1470962503-19682-6-git-send-email-xiyou.wangcong@gmail.com>
 <70a062d7-5670-b71a-1ead-045a7b1426f5@mojatatu.com>
 <CAM_iQpUUb7Uwx35qcCWgf6_poawtNnVZUJwvGOUqFZ76YD22Ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33744 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933172AbcHNLA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:00:27 -0400
Received: by mail-qk0-f196.google.com with SMTP id x189so2349141qkd.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:00:27 -0700 (PDT)
In-Reply-To: <CAM_iQpUUb7Uwx35qcCWgf6_poawtNnVZUJwvGOUqFZ76YD22Ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:03 AM, Cong Wang wrote:
> On Sat, Aug 13, 2016 at 4:33 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>
>> Just minor comment below:
>>
>> On 16-08-11 08:41 PM, Cong Wang wrote:
>>
>>
>>> +static inline void
>>> +tcf_exts_to_list(const struct tcf_exts *exts, struct list_head *actions)
>>> +{
>>
>>
>> to:
>> static inline void tcf_exts_to_list(const struct tcf_exts *exts,
>>                                     struct list_head *actions)
>
> I don't disagree, just want to point out that other functions
> in this header use similar indention. I am fine with either.
>

True - but if you introduce a new one you should use new style
(and it is an opportunity to fix the others).

Thanks for being dilligent on this. I dont have time to test the patches
for about a day but i see no reason to delay them, so I will proceed to
do so.

cheers,
jamal
