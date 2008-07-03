From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 06/39]: netdev: ->ingress_lock is no longer needed.
Date: Thu, 03 Jul 2008 17:55:30 +0800
Message-ID: <486CA212.6020705@cn.fujitsu.com>
References: <20080703.000303.167904111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080703.000303.167904111.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2008-7-3 15:03:
> @@ -2014,10 +2014,11 @@ static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
>   */
>  static int ing_filter(struct sk_buff *skb)
>  {
> -	struct Qdisc *q;
>  	struct net_device *dev = skb->dev;
> -	int result = TC_ACT_OK;
>  	u32 ttl = G_TC_RTTL(skb->tc_verd);
> +	struct netdev_queue *rxq;
> +	int result = TC_ACT_OK;
> +	struct Qdisc *q;
>  

Two lines do not change anything.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
