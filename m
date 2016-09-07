From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V6 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 7 Sep 2016 09:27:58 -0700
Message-ID: <CAM_iQpUDqM4s4+VYpyPXhrFE4vTuEQorj2_nJrtM75y548hDHA@mail.gmail.com>
References: <1473235686-18975-1-git-send-email-hadarh@mellanox.com>
 <1473235686-18975-5-git-send-email-hadarh@mellanox.com> <1473257660.10725.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38681 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933159AbcIGQ2T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:28:19 -0400
Received: by mail-it0-f54.google.com with SMTP id c198so31561627ith.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 09:28:19 -0700 (PDT)
In-Reply-To: <1473257660.10725.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 7:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-09-07 at 11:08 +0300, Hadar Hen Zion wrote:
>> From: Amir Vadai <amir@vadai.me>
>>
>
>
>> +static int tunnel_key_init(struct net *net, struct nlattr *nla,
>> +                        struct nlattr *est, struct tc_action **a,
>> +                        int ovr, int bind)
>> +{
>> +     struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
>> +     struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
>> +     struct metadata_dst *metadata = NULL;
>> +     struct tc_tunnel_key *parm;
>> +     struct tcf_tunnel_key *t;
>> +     struct tcf_tunnel_key_params *params_old;
>> +     struct tcf_tunnel_key_params *params_new;
>> +     __be64 key_id;
>> +     bool exists = false;
>> +     int ret = 0;
>> +     int err;
>
> We try for new code to avoid reverse Christmas tree ;)

Fix checkpatch.pl (or whatever tool you prefer).
