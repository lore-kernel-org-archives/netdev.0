From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 3/6] net sched: mirred action fix late binding
Date: Sun, 8 May 2016 20:19:05 -0700
Message-ID: <CAM_iQpWjQsJTRVoE2nf4SxY=YF-0q4j6kDD8fJDLq3K=2QWwLw@mail.gmail.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com> <1462728392-28489-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:36857 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbcEIDTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:19:25 -0400
Received: by mail-yw0-f173.google.com with SMTP id o66so273586840ywc.3
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 20:19:25 -0700 (PDT)
In-Reply-To: <1462728392-28489-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> -static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
> +static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
> +                          int ref)
>  {
>         unsigned char *b = skb_tail_pointer(skb);
>         struct tcf_mirred *m = a->priv;

Nit: this is irrelevant to the bug you fix.
