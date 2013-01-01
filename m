From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] vxlan: allow live mac address change
Date: Tue, 1 Jan 2013 09:19:49 +0100
Message-ID: <20130101081949.GA1531@minipsycho.orion>
References: <20121231140021.5ec82f3a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:33552 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3AAITx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 03:19:53 -0500
Received: by mail-ea0-f171.google.com with SMTP id n10so5334756eaa.30
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 00:19:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121231140021.5ec82f3a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 31, 2012 at 11:00:21PM CET, shemminger@vyatta.com wrote:
>The VXLAN pseudo-device doesn't care if the mac address changes
>when device is up.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
>--- a/drivers/net/vxlan.c	2012-12-27 22:30:53.630796042 -0800
>+++ b/drivers/net/vxlan.c	2012-12-31 10:46:25.435321912 -0800
>@@ -1191,6 +1191,7 @@ static void vxlan_setup(struct net_devic
> 
> 	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
> 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
>+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
> 
> 	spin_lock_init(&vxlan->hash_lock);
> 

Reviewed-by: Jiri Pirko <jiri@resnulli.us>


>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
