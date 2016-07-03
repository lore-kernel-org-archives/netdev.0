From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RDS: fix rds_tcp_init() error path
Date: Sun, 3 Jul 2016 11:34:30 -0700
Message-ID: <169e7f59-26d9-dbae-8710-ff4dcf1cfdde@oracle.com>
References: <1467536094-23722-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vegard Nossum <vegard.nossum-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467536094-23722-1-git-send-email-vegard.nossum-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7/3/2016 1:54 AM, Vegard Nossum wrote:
> If register_pernet_subsys() fails, we shouldn't try to call
> unregister_pernet_subsys().
>
> Fixes: 467fa15356 ("RDS-TCP: Support multiple RDS-TCP listen endpoints, one per netns.")
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Signed-off-by: Vegard Nossum <vegard.nossum-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
