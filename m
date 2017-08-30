From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] sch_hhf: fix null pointer dereference on init failure
Date: Wed, 30 Aug 2017 10:27:20 +0300
Message-ID: <04bea369-e2d9-954a-0da0-eb3ff831a1c7@cumulusnetworks.com>
References: <1504033335-19098-1-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpWN6bubnnFfqoZeiuH5NF3tpQ7nb91CBp09Yw-NJzRcng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:36199 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751242AbdH3H1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 03:27:23 -0400
Received: by mail-wr0-f173.google.com with SMTP id p14so16020202wrg.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 00:27:23 -0700 (PDT)
In-Reply-To: <CAM_iQpWN6bubnnFfqoZeiuH5NF3tpQ7nb91CBp09Yw-NJzRcng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/17 04:24, Cong Wang wrote:
> On Tue, Aug 29, 2017 at 12:02 PM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> First I did it with the check in the for () conditional, but this is more
>> visible and explicit. Let me know if you'd like the shorter version. :-)
> 
> Or, if you want to make the patch size smaller, just check NULL
> before for():
> 
> if (!q->hh_flows)
>     return;
> 
> for (...)
> 
> Up to you, I have no strong opinion here, slightly prefer a smaller
> one for backport.
> 

Sure, either one is fine with me too. Since I'll be resubmitting these in a set
I'll use the smaller version for this one.

Thanks,
 Nik
