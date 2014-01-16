From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: act: pick a different type for act_xt
Date: Thu, 16 Jan 2014 08:28:47 -0500
Message-ID: <52D7DE8F.9070504@mojatatu.com>
References: <1389829123-22914-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:45727 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804AbaAPN2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:28:49 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so7556723igb.3
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 05:28:48 -0800 (PST)
In-Reply-To: <1389829123-22914-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/14 18:38, Cong Wang wrote:
> In tcf_register_action() we check either ->type or ->kind to see if
> there is an existing action registered, but ipt action registers two
> actions with same type but different kinds. They should have different
> types too.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal

> ---
>   include/uapi/linux/tc_act/tc_ipt.h | 1 +
>   net/sched/act_ipt.c                | 2 +-
>   2 files changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/tc_act/tc_ipt.h b/include/uapi/linux/tc_act/tc_ipt.h
> index a233556..130aaad 100644
> --- a/include/uapi/linux/tc_act/tc_ipt.h
> +++ b/include/uapi/linux/tc_act/tc_ipt.h
> @@ -4,6 +4,7 @@
>   #include <linux/pkt_cls.h>
>
>   #define TCA_ACT_IPT 6
> +#define TCA_ACT_XT 10
>
>   enum {
>   	TCA_IPT_UNSPEC,
> diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
> index 484bd19..bc9f498 100644
> --- a/net/sched/act_ipt.c
> +++ b/net/sched/act_ipt.c
> @@ -298,7 +298,7 @@ static struct tc_action_ops act_ipt_ops = {
>   static struct tc_action_ops act_xt_ops = {
>   	.kind		=	"xt",
>   	.hinfo		=	&ipt_hash_info,
> -	.type		=	TCA_ACT_IPT,
> +	.type		=	TCA_ACT_XT,
>   	.capab		=	TCA_CAP_NONE,
>   	.owner		=	THIS_MODULE,
>   	.act		=	tcf_ipt,
>
