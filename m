From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V5 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 06 Sep 2016 07:11:34 -0700
Message-ID: <1473171094.10725.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
         <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
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
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35769 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756376AbcIFOLi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 10:11:38 -0400
Received: by mail-pa0-f68.google.com with SMTP id pp5so4551936pac.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 07:11:38 -0700 (PDT)
In-Reply-To: <1472986555-14949-5-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-09-04 at 13:55 +0300, Hadar Hen Zion wrote:
> From: Amir Vadai <amir@vadai.me>

...

> +struct tcf_tunnel_key_params {
> +	struct rcu_head		rcu;
> +	int			tcft_action;
> +	int			action;
> +	struct metadata_dst     *tcft_enc_metadata;
> +};
> +
> +struct tcf_tunnel_key {
> +	struct tc_action	      common;
> +	struct tcf_tunnel_key_params *params;

In order to please sparse you must add __rcu qualifier, as in :

struct tcf_tunnel_key_params __rcu *params;

> +};
> +

Thanks.
