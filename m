From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Thu, 08 Sep 2016 08:51:40 -0700
Message-ID: <1473349900.15733.59.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
         <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
         <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <57D0FF87.604@gmail.com>
         <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
         <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
         <57D1881B.6090009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33228 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbcIHPvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:51:42 -0400
Received: by mail-pf0-f178.google.com with SMTP id g202so19498324pfb.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:51:41 -0700 (PDT)
In-Reply-To: <57D1881B.6090009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 08:47 -0700, John Fastabend wrote:

> Works for me. FWIW I find this plenty straightforward and don't really
> see the need to make the hash table itself rcu friendly.
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 

Yes, it seems this hash table is used in control path, with RTNL held
anyway.

Thanks for reviewing John.
