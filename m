From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 19:26:21 -0400
Message-ID: <e87b4c7f-b57f-fd6f-768e-d53c96a350c8@mojatatu.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
 <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
 <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
 <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
 <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33732 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752163AbcILX0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:26:24 -0400
Received: by mail-oi0-f52.google.com with SMTP id y2so343942368oie.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:26:23 -0700 (PDT)
In-Reply-To: <3a1da0eb-b253-ef9c-8679-0290e670238c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 07:02 PM, Jamal Hadi Salim wrote:

>> Looks like typical starvation caused by aggressive softirq.
>>
>
> Well, then it is strange that in one case a tc dump of the rule
> was immediate and in the other case it was consistent for 5-15
> seconds.
>

I may be going nuts because i cant reproduce that issue anymore.
VM is configured for SMP 4 vcpus.

I will remove that check and submit a new version.

cheers,
jamal
