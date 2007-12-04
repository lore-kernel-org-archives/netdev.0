From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PASEMI_MAC] Don't claim to do IPv6 checksum offload
Date: Tue, 04 Dec 2007 14:54:08 -0500
Message-ID: <4755B060.8020406@pobox.com>
References: <1196656472.13978.130.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47966 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458AbXLDTyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 14:54:13 -0500
In-Reply-To: <1196656472.13978.130.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
> index 09b4fde..a8db5d7 100644
> --- a/drivers/net/pasemi_mac.c
> +++ b/drivers/net/pasemi_mac.c
> @@ -1362,7 +1362,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
>  
> -	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
> +	dev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX | NETIF_F_SG;

applied #upstream-fixes


