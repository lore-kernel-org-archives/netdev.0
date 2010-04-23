From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sky2: add support for receive hashing
Date: Thu, 22 Apr 2010 17:02:38 -0700 (PDT)
Message-ID: <20100422.170238.195064226.davem@davemloft.net>
References: <20100422234255.150547953@vyatta.com>
	<20100422234319.149785036@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754066Ab0DWACf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 20:02:35 -0400
In-Reply-To: <20100422234319.149785036@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 22 Apr 2010 16:42:57 -0700

> @@ -4491,6 +4565,11 @@ static __devinit struct net_device *sky2
>  	if (highmem)
>  		dev->features |= NETIF_F_HIGHDMA;
>  
> +#ifdef CONFIG_RPS
> +	if (!(hw->flags & SKY2_HW_RSS_BROKEN))
> +		dev->features |= NETIF_F_RXHASH;
> +#endif
> +
>  #ifdef SKY2_VLAN_TAG_USED

Stephen, I asked you to drop this CONFIG_RPS check.

Please do it and resubmit.
