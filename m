From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 11:29:06 -0800
Message-ID: <CAM_iQpW_=yMpEVPnpgXNJm8161DUMwx75NP0rMFFU+_Z9GN5WQ@mail.gmail.com>
References: <20160301174233.GO16369@oracle.com>
	<CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
	<20160301182102.GR16369@oracle.com>
	<CAM_iQpXwd9fQqEh1o56fVqoxUYC5ctY9wqjkAA7UeGru+T8bjw@mail.gmail.com>
	<20160301184119.GS16369@oracle.com>
	<CAM_iQpXDo5Lh+MF7yds3vDyn7D-aqKH3-9kmVYZ924QkAw=imA@mail.gmail.com>
	<20160301190917.GU16369@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34947 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbcCAT3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 14:29:08 -0500
Received: by mail-yw0-f177.google.com with SMTP id g127so157824412ywf.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 11:29:08 -0800 (PST)
In-Reply-To: <20160301190917.GU16369@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 11:09 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/01/16 10:51), Cong Wang wrote:
>> --- a/net/sched/sch_mqprio.c
>> +++ b/net/sched/sch_mqprio.c
>> @@ -142,7 +142,7 @@ static int mqprio_init(struct Qdisc *sch, struct
>> nlattr *opt)
>>          */
>>         if (qopt->hw) {
>>                 struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
>> -                                         .tc = qopt->num_tc};
>> +                                         {.tc = qopt->num_tc} };
>>
>
> this fix works.
>
> The first suggestion had no effect (needs changes to a lot of files
> I suspect).
>

It must work, you just didn't try it hard.

> BTW, I remain surprised that no one else has noticed this. It did not
> take me any effort to reproduce it on an x86.

I think that is probably because most people use newer gcc, at least
I don't see any compile error with gcc 4.9.2.
