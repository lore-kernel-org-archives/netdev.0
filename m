From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-2.6 PATCH] af_packet: move strict addr_len check right
 before dev_[mc/unicast]_[add/del]
Date: Wed, 03 Mar 2010 01:06:41 -0800 (PST)
Message-ID: <20100303.010641.04067796.davem@davemloft.net>
References: <1267578048.14049.11.camel@mj>
	<20100303064001.GB2648@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tcpdump-workers-YE1jQ5a0g24KACXWX4p+q9i2O/JbrIOy@public.gmane.org, proski-mXXj517/zsQ@public.gmane.org
To: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100303064001.GB2648-YzwxZg+R7et1/kRsl7OVgNvLeJWuRmrY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 3 Mar 2010 07:40:01 +0100

> Subject: [net-2.6 PATCH] af_packet: move strict addr_len check right before dev_[mc/unicast]_[add/del]
> 
> My previous patch 914c8ad2d18b62ad1420f518c0cab0b0b90ab308 incorrectly changed
> the length check in packet_mc_add to be more strict. The problem is that
> userspace is not filling this field (and it stays zeroed) in case of setting
> PACKET_MR_PROMISC or PACKET_MR_ALLMULTI. So move the strict check to the point
> in path where the addr_len must be set correctly.
> 
> Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
