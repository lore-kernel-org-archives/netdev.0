From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 5/5] Support to encoding decoding skb queue map
 on IFE action
Date: Mon, 22 Feb 2016 17:59:31 +0100
Message-ID: <56CB3E73.10803@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <1456147304-13355-6-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38856 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbcBVQ7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 11:59:34 -0500
In-Reply-To: <1456147304-13355-6-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2016 02:21 PM, Jamal Hadi Salim wrote:
[...]
> Note: as of the time of submission skbedit of queue map doesnt work
> (just in case you try to use it)

Yep, setting queue mapping doesn't work. ;)

> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   net/sched/Kconfig         |   5 +++
>   net/sched/Makefile        |   1 +
>   net/sched/act_meta_qmap.c | 100 ++++++++++++++++++++++++++++++++++++++++++++++
[...]
> +static int __init ifeqmap_init_module(void)
> +{
> +	pr_emerg("Loaded IFE qmap\n");

pr_emerg() means "system is unusable" ... ;)

> +	return register_ife_op(&ife_qmap_ops);
> +}
> +
> +static void __exit ifeqmap_cleanup_module(void)
> +{
> +	pr_emerg("Unloaded IFE qmap\n");
> +	unregister_ife_op(&ife_qmap_ops);
> +}
> +
> +module_init(ifeqmap_init_module);
> +module_exit(ifeqmap_cleanup_module);
> +
> +MODULE_AUTHOR("Jamal Hadi Salim(2015)");
> +MODULE_DESCRIPTION("Inter-FE skb qmap metadata action");
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS_IFE_META(IFE_META_QMAP);
>
