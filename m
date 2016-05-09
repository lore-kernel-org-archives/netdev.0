From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/6] net sched: vlan action fix late binding
Date: Mon, 9 May 2016 07:50:21 -0400
Message-ID: <5730797D.9020100@mojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
 <1462728392-28489-2-git-send-email-jhs@emojatatu.com>
 <CAM_iQpVtk1AowsH_jDz24yNqAZTCOPtMk=KM0dhFtYUJLfOk4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37238 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcEILuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 07:50:24 -0400
Received: by mail-ig0-f178.google.com with SMTP id s8so89438967ign.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 04:50:24 -0700 (PDT)
In-Reply-To: <CAM_iQpVtk1AowsH_jDz24yNqAZTCOPtMk=KM0dhFtYUJLfOk4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 11:08 PM, Cong Wang wrote:
> On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
[..]
>> +       aexists = tcf_hash_check(tn, parm->index, a, bind);
>
>
> I think 'exists' is a better name than 'aexists', shorter and clear.
>

aexists is more specific (doesnt quiet apply to this case but has better
grep-ability).
exists looked too generic - initially I was going to have act_exists. 
Yes, it is a tiny but ocd detail. Let me know if you feel strongly
and i will change it in next update.

>> +               if (aexists)
>> +                       tcf_hash_release(a, bind);
>
>
> Introduce a goto to reduce duplicated cleanup code?
>

Will do.

cheers,
jamal
