From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] netprio_cgroup: define sk_cgrp_prioidx only if
 NETPRIO_CGROUP is enabled
Date: Wed, 26 Dec 2012 13:03:39 -0500
Message-ID: <20121226180339.GB10793@neilslaptop.think-freely.org>
References: <50DA9DB8.6080506@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50DA9DB8.6080506-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 26, 2012 at 02:48:24PM +0800, Li Zefan wrote:
> sock->sk_cgrp_prioidx won't be used at all if CONFIG_NETPRIO_CGROUP=n.
> 
> Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

> ---
>  include/net/sock.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 93a6745..182ca99 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -367,7 +367,7 @@ struct sock {
>  	unsigned short		sk_ack_backlog;
>  	unsigned short		sk_max_ack_backlog;
>  	__u32			sk_priority;
> -#ifdef CONFIG_CGROUPS
> +#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
>  	__u32			sk_cgrp_prioidx;
>  #endif
>  	struct pid		*sk_peer_pid;
> -- 
> 1.8.0.2
> 
> 
