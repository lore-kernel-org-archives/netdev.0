From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] act_mirred: fix a typo in get_dev
Date: Sat, 03 Dec 2016 10:59:18 -0800
Message-ID: <1480791558.18162.406.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480790161-8097-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36486 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcLCS7n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 13:59:43 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so11445039pgx.3
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 10:59:20 -0800 (PST)
In-Reply-To: <1480790161-8097-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-12-03 at 10:36 -0800, Cong Wang wrote:
> Cc: Hadar Hen Zion <hadarh@mellanox.com>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/act_mirred.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index bb09ba3..2d9fa6e 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -321,7 +321,7 @@ static int tcf_mirred_device(const struct tc_action *a, struct net *net,
>  	int ifindex = tcf_mirred_ifindex(a);
>  
>  	*mirred_dev = __dev_get_by_index(net, ifindex);
> -	if (!mirred_dev)
> +	if (!*mirred_dev)
>  		return -EINVAL;
>  	return 0;
>  }

Fixes: 255cb30425c0 ("net/sched: act_mirred: Add new tc_action_ops get_dev()")
Acked-by: Eric Dumazet <edumazet@google.com>
