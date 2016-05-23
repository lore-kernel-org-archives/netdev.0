From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net PATCH 1/1] net sched actions: policer missing timestamp processing
Date: Mon, 23 May 2016 13:52:07 -0700
Message-ID: <CAM_iQpWhRRqJWNaRXbFSPEVu+CTSb++z8A5Y3SB-vjmk1-gXmw@mail.gmail.com>
References: <1463935423-8918-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34647 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbcEWUw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 16:52:28 -0400
Received: by mail-yw0-f193.google.com with SMTP id j74so6398333ywg.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 13:52:27 -0700 (PDT)
In-Reply-To: <1463935423-8918-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2016 at 9:43 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> @@ -340,6 +345,11 @@ tcf_act_police_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
>         if (police->tcfp_ewma_rate &&
>             nla_put_u32(skb, TCA_POLICE_AVRATE, police->tcfp_ewma_rate))
>                 goto nla_put_failure;
> +
> +       tcf_tm_dump(&t, &police->tcf_tm);

This depends on a previous patch you sent, right?
