From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH RFC] 2/2 huawei_cdc_ncm: introduce new TX ncm stack
Date: Thu, 25 Jun 2015 11:55:08 +0200
Message-ID: <1435226108.28594.15.camel@suse.com>
References: <1435012335-6055-1-git-send-email-mrkiko.rs@gmail.com>
	 <1435012335-6055-3-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1435012335-6055-3-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-06-23 at 00:32 +0200, Enrico Mioso wrote:

> +/* XXX rewrite, not multipacket */

Can you explain what you want to do here?
> +struct sk_buff *
> +huawei_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb_in, gfp_t flags) {
> +	struct huawei_cdc_ncm_state *drvstate = (void *)&dev->data;
> +	struct cdc_ncm_ctx *ctx = drvstate->ctx;
> +	struct sk_buff *skb_out;
> +	int status;
> +
> +	skb_out = alloc_skb(ctx->tx_max, GFP_ATOMIC);

You must test this for NULL

	Regards
		Oliver



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
