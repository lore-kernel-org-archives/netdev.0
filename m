From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V6 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 07 Sep 2016 07:14:20 -0700
Message-ID: <1473257660.10725.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473235686-18975-1-git-send-email-hadarh@mellanox.com>
         <1473235686-18975-5-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33555 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbcIGOOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:14:25 -0400
Received: by mail-pa0-f41.google.com with SMTP id cm16so6860159pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:14:25 -0700 (PDT)
In-Reply-To: <1473235686-18975-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 11:08 +0300, Hadar Hen Zion wrote:
> From: Amir Vadai <amir@vadai.me>
> 


> +static int tunnel_key_init(struct net *net, struct nlattr *nla,
> +			   struct nlattr *est, struct tc_action **a,
> +			   int ovr, int bind)
> +{
> +	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
> +	struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
> +	struct metadata_dst *metadata = NULL;
> +	struct tc_tunnel_key *parm;
> +	struct tcf_tunnel_key *t;
> +	struct tcf_tunnel_key_params *params_old;
> +	struct tcf_tunnel_key_params *params_new;
> +	__be64 key_id;
> +	bool exists = false;
> +	int ret = 0;
> +	int err;

We try for new code to avoid reverse Christmas tree ;)

->

+       struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
+       struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
+       struct tcf_tunnel_key_params *params_old;
+       struct tcf_tunnel_key_params *params_new;
+       struct metadata_dst *metadata = NULL;
+       struct tc_tunnel_key *parm;
+       struct tcf_tunnel_key *t;
+       bool exists = false;
+       __be64 key_id;
+       int ret = 0;
+       int err;


Other than this, code looks fine to me, thanks.
