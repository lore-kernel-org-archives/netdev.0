From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 10:23:44 -0800
Message-ID: <CAM_iQpXwd9fQqEh1o56fVqoxUYC5ctY9wqjkAA7UeGru+T8bjw@mail.gmail.com>
References: <20160301174233.GO16369@oracle.com>
	<CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
	<20160301182102.GR16369@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:34027 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbcCASXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:23:45 -0500
Received: by mail-yw0-f172.google.com with SMTP id h129so156038599ywb.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 10:23:45 -0800 (PST)
In-Reply-To: <20160301182102.GR16369@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 10:21 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/01/16 10:13), Cong Wang wrote:
>> > net/sched/sch_mqprio.c: In function `mqprio_init':
>> > net/sched/sch_mqprio.c:145: error: unknown field `tc' specified in initializer
>     :
>> Why not just initialize these fields explicitly? For example,
>>
>> +       struct tc_to_netdev tc;
>              :
>> +       tc.type = TC_SETUP_MQPRIO;
>
> The compiler error is for fields within the union which lacks
> both a tag and a union-name.  So I'm not sure how the above will
> help.
>

Come on.. we have plenty of such anonymous unions in skbuff.h...
