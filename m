From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Thu, 8 Sep 2016 22:26:45 -0700
Message-ID: <CAM_iQpV+ybrM_ebgwX5ZohmKvWZo-8znXkgJv1LhDAC9=3u9Xw@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com> <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D1881B.6090009@gmail.com> <1473349900.15733.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35421 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcIIF1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:27:07 -0400
Received: by mail-oi0-f68.google.com with SMTP id 2so8199236oif.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:27:06 -0700 (PDT)
In-Reply-To: <1473349900.15733.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 8:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-09-08 at 08:47 -0700, John Fastabend wrote:
>
>> Works for me. FWIW I find this plenty straightforward and don't really
>> see the need to make the hash table itself rcu friendly.
>>
>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>
>
> Yes, it seems this hash table is used in control path, with RTNL held
> anyway.

Seriously? You never read hashtable in fast path?? I think you need
to wake up.
