From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 3/4] net: sched: convert cls_flower->egress_dev
 users to tc_setup_cb_egdev infra
Date: Tue, 10 Oct 2017 23:04:43 +0300
Message-ID: <CAJ3xEMgRv3fVD3aBYMmyDjSeN+xoh-q71_aVkqyCNE7czpetwg@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us> <20171010073016.3682-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36993 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934898AbdJJUEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:04:44 -0400
Received: by mail-oi0-f67.google.com with SMTP id 82so4378896oid.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 13:04:44 -0700 (PDT)
In-Reply-To: <20171010073016.3682-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -206,8 +206,6 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
>  int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
>  int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
>                      struct net_device **hw_dev);
> -int tcf_exts_egdev_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
> -                          void *type_data, bool err_stop);

but this (and another 1-2 hunks below) were set by upstream patch of
this series, did you do that add/del on purpose? is that for
bisection? if not why?
