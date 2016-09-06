From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 6 Sep 2016 17:25:55 +0300
Message-ID: <CAJL1qvEawkHveuZU3qxy0i9gk67NipPq3tq+kg0AWjVLvxJUMQ@mail.gmail.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
 <1472986555-14949-5-git-send-email-hadarh@mellanox.com> <1473171094.10725.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33135 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753966AbcIFOZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 10:25:57 -0400
Received: by mail-oi0-f66.google.com with SMTP id w78so9305707oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 07:25:56 -0700 (PDT)
In-Reply-To: <1473171094.10725.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 5:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-09-04 at 13:55 +0300, Hadar Hen Zion wrote:
>> From: Amir Vadai <amir@vadai.me>
>
> ...
>
>> +struct tcf_tunnel_key_params {
>> +     struct rcu_head         rcu;
>> +     int                     tcft_action;
>> +     int                     action;
>> +     struct metadata_dst     *tcft_enc_metadata;
>> +};
>> +
>> +struct tcf_tunnel_key {
>> +     struct tc_action              common;
>> +     struct tcf_tunnel_key_params *params;
>
> In order to please sparse you must add __rcu qualifier, as in :
>
> struct tcf_tunnel_key_params __rcu *params;

Thanks!


>
>> +};
>> +
>
> Thanks.
>
>
>
