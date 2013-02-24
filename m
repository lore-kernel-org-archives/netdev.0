From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/pasemi: Fix missing coding style
Date: Sun, 24 Feb 2013 15:23:05 -0800
Message-ID: <1361748185.2281.2.camel@joe-AO722>
References: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, olof@lixom.net
To: Syam Sidhardhan <syamsidhardh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40974 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757801Ab3BXXXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2013 18:23:07 -0500
In-Reply-To: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-25 at 04:31 +0530, Syam Sidhardhan wrote:
> Fix missing () & { }
[]
> diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
[]
> @@ -1829,10 +1831,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
>  			err);
>  		goto out;
> -	} else if netif_msg_probe(mac)
> +	} else if (netif_msg_probe(mac)) {
>  		printk(KERN_INFO "%s: PA Semi %s: intf %d, hw addr %pM\n",
>  		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
>  		       mac->dma_if, dev->dev_addr);
> +	}
>  
>  	return err;
>  

Uncompilable since 2007!

That argues more for removal than anything else.
