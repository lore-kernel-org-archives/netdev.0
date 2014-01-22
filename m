From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: netfilter_arp: use __u8 instead of u_int8_t
Date: Tue, 21 Jan 2014 18:47:32 -0800 (PST)
Message-ID: <20140121.184732.814241116305351762.davem@davemloft.net>
References: <1390358414-8844-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1390358414-8844-1-git-send-email-vapier@gentoo.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 21 Jan 2014 21:40:14 -0500

> Subject: [PATCH] uapi: netfilter_arp: use __u8 instead of u_int8_t
> From:	Mike Frysinger <vapier@gentoo.org>
> To:	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
> Date:	Tue, 21 Jan 2014 21:40:14 -0500
> Sender:	netdev-owner@vger.kernel.org
> X-Mailer: git-send-email 1.8.4.3
> 
> Similarly, the u_int8_t type is non-standard and not defined.  Change
> it to use __u8 like the rest of the netfilter headers.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Please send netfilter changes to netfilter-devel, CC:'d.

> ---
>  include/uapi/linux/netfilter_arp/arpt_mangle.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/netfilter_arp/arpt_mangle.h b/include/uapi/linux/netfilter_arp/arpt_mangle.h
> index 250f502..8c2b16a 100644
> --- a/include/uapi/linux/netfilter_arp/arpt_mangle.h
> +++ b/include/uapi/linux/netfilter_arp/arpt_mangle.h
> @@ -13,7 +13,7 @@ struct arpt_mangle
>  	union {
>  		struct in_addr tgt_ip;
>  	} u_t;
> -	u_int8_t flags;
> +	__u8 flags;
>  	int target;
>  };
>  
> -- 
> 1.8.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
