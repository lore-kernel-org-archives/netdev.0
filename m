From: "Bryan Wu" <cooloney@kernel.org>
Subject: Re: [PATCH] blackfin_mac: unneeded assignment
Date: Tue, 29 Jul 2008 14:48:18 +0800
Message-ID: <386072610807282348q10ae9a47k7b0a3859f561522e@mail.gmail.com>
References: <20080725114646.35f99145@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:46742 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbYG2GsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 02:48:19 -0400
Received: by qw-out-2122.google.com with SMTP id 3so432034qwe.37
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 23:48:18 -0700 (PDT)
In-Reply-To: <20080725114646.35f99145@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 26, 2008 at 2:46 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> skb->dev is set by eth_type_trans already.
>

Right, I'd love to add it into my queue.
Applied.

Acked-by: Bryan Wu <cooloney@kernel.org>

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
> --- a/drivers/net/bfin_mac.c    2008-07-25 10:19:53.000000000 -0700
> +++ b/drivers/net/bfin_mac.c    2008-07-25 10:20:53.000000000 -0700
> @@ -691,7 +691,6 @@ static void bfin_mac_rx(struct net_devic
>                                         (unsigned long)skb->tail);
>
>        dev->last_rx = jiffies;
> -       skb->dev = dev;
>        skb->protocol = eth_type_trans(skb, dev);
>  #if defined(BFIN_MAC_CSUM_OFFLOAD)
>        skb->csum = current_rx_ptr->status.ip_payload_csum;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
