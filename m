From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/3] net_sched: fix some checkpatch errors
Date: Wed, 6 Nov 2013 07:37:41 -0800
Message-ID: <20131106073741.154f8590@samsung-9>
References: <1383725109-37348-1-git-send-email-yangyingliang@huawei.com>
	<1383725109-37348-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <jhs@mojatatu.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48553 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab3KFPhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 10:37:46 -0500
Received: by mail-pb0-f46.google.com with SMTP id un15so4152718pbc.5
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 07:37:45 -0800 (PST)
In-Reply-To: <1383725109-37348-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Nov 2013 16:05:08 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index fd70728..c8aadfa 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -191,7 +191,7 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
>  			val = 1;
>  	} while (tcf_hash_lookup(val, hinfo));
>  
> -	return (*idx_gen = val);
> +	return *idx_gen = val;

That is not an improvement. I would rather see the return on a assingment and return
on separate lines.
