From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 1/6] net_sched: act: fetch hinfo from a->ops->hinfo
Date: Mon, 20 Jan 2014 07:16:37 -0500
Message-ID: <52DD13A5.6070502@mojatatu.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com> <1389987427-14085-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:43260 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaATMQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 07:16:51 -0500
Received: by mail-ig0-f174.google.com with SMTP id hl1so7770719igb.1
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 04:16:51 -0800 (PST)
In-Reply-To: <1389987427-14085-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/14 14:37, Cong Wang wrote:
> Every action ops has a pointer to hash info, so we don't need to
> hard-code it in each module.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Although changes like the one below (which are in a few places)
are necessary i.e it was more readable before.


> diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
> index ee28e1c..a9a3185 100644
> --- a/net/sched/act_csum.c
> +++ b/net/sched/act_csum.c

> -		tcf_hash_release(pc, bind, &csum_hash_info);
> +		tcf_hash_release(pc, bind, a->ops->hinfo);
>   		if (!ovr)

cheers,
jamal
