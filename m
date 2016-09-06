From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 6 Sep 2016 08:44:55 -0400
Message-ID: <6b4fc960-ee0a-c85a-13eb-fe33c36bef4a@mojatatu.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
 <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
 <b6d6b736-bc45-3216-6109-0b67a54fb704@mojatatu.com>
 <CAJL1qvEP7NOMr1xGr1LkUDi9K96P+ZzU2m5D1q=uZMC-AyrKSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33852 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932286AbcIFMpQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:45:16 -0400
Received: by mail-oi0-f66.google.com with SMTP id v82so7498735oie.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:45:16 -0700 (PDT)
In-Reply-To: <CAJL1qvEP7NOMr1xGr1LkUDi9K96P+ZzU2m5D1q=uZMC-AyrKSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-06 07:03 AM, Hadar Hen Zion wrote:
> On Tue, Sep 6, 2016 at 1:49 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>> Please verify by running a test and send a packet or two
>> and verify that stats are incremented (I know it may sound silly to
>> ask but it is important).
>
> Already tested that tc filter stats are working and incremented as expected :-)

I did see issue with per-cpu counters when i updated to rcu.
But the test was on a VM. So i changed skbmod to use global stats.
Maybe the kernel i was testing had issues.
Eric may have some insights.

cheers,
jamal
