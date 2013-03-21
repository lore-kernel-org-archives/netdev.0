From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: remove redundant ifdef CONFIG_CGROUPS
Date: Thu, 21 Mar 2013 07:22:23 -0400
Message-ID: <20130321112223.GA28416@hmsreliant.think-freely.org>
References: <514A767B.7000307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55734 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755344Ab3CULWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 07:22:44 -0400
Content-Disposition: inline
In-Reply-To: <514A767B.7000307@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 10:54:51AM +0800, Li Zefan wrote:
> The cgroup code has been surrounded by ifdef CONFIG_NET_CLS_CGROUP
> and CONFIG_NETPRIO_CGROUP.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>  net/core/sock.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index b261a79..a19e728 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1298,7 +1298,6 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
>  	module_put(owner);
>  }
>  
> -#ifdef CONFIG_CGROUPS
>  #if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
>  void sock_update_classid(struct sock *sk, struct task_struct *task)
>  {
> @@ -1321,7 +1320,6 @@ void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
>  }
>  EXPORT_SYMBOL_GPL(sock_update_netprioidx);
>  #endif
> -#endif
>  
>  /**
>   *	sk_alloc - All socket objects are allocated here
> -- 
> 1.8.0.2
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
