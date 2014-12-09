From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v7 2/3] net: Add Keystone NetCP ethernet driver
Date: Tue, 09 Dec 2014 13:10:53 -0500 (EST)
Message-ID: <20141209.131053.2026868499542642866.davem@davemloft.net>
References: <1417556503-22290-1-git-send-email-m-karicheri2@ti.com>
	<1417556503-22290-3-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, sandeep_n-l0cyMroinI0@public.gmane.org,
	santosh.shilimkar-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: m-karicheri2-l0cyMroinI0@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417556503-22290-3-git-send-email-m-karicheri2-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Date: Tue, 2 Dec 2014 16:41:42 -0500

> +static void set_pkt_info_le(u32 buff, u32 buff_len, u32 ndesc,
> +			    struct knav_dma_desc *desc)
> +{
> +	desc->buff_len = cpu_to_le32(buff_len);
> +	desc->buff = cpu_to_le32(buff);
> +	desc->next_desc = cpu_to_le32(ndesc);
> +}

The members of knav_dma_desc are "u32", so you are going to get tons of
static checker warnings from trying to assign cpu_to_le32()'s result
(which is a le32) into them.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
