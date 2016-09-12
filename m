From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 19:02:35 -0400
Message-ID: <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
 <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
 <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36522 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbcILXCq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:02:46 -0400
Received: by mail-it0-f46.google.com with SMTP id o3so26833780ita.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:02:46 -0700 (PDT)
In-Reply-To: <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 06:26 PM, Eric Dumazet wrote:
> On Mon, 2016-09-12 at 18:14 -0400, Jamal Hadi Salim wrote:
>
>> I noticed some very weird issues when I took that out.
>> Running sufficiently large amount of traffic (ping -f is sufficient)
>> I saw that when i did a dump it took anywhere between 6-15 seconds.
>> With the read_lock in place response was immediate.
>> I can go back and run things to verify - but it was very odd.
>
> This was on uni processor ?
>

It was a VM.

> Looks like typical starvation caused by aggressive softirq.
>

Well, then it is strange that in one case a tc dump of the rule
was immediate and in the other case it was consistent for 5-15
seconds.

> Anyway, I suspect your kernel build has rcu_read_lock() and
> rcu_read_unlock() as NOP ;)
>

Which doesnt give me a good feel if i tested this well ;->

I would like to try again with those two kernels just to
make sure i was not imagining this.

cheers,
jamal
