From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in
 driver initialization
Date: Thu, 29 May 2014 15:28:09 -0700 (PDT)
Message-ID: <20140529.152809.871745461296745132.davem@davemloft.net>
References: <5380EAF6.1090402@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaE2W2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 18:28:10 -0400
In-Reply-To: <5380EAF6.1090402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Sun, 25 May 2014 00:24:46 +0530

> @@ -2525,6 +2525,8 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>  
>  	netdev_info(dev, "MAC Address: %pM\n", dev->dev_addr);
>  
> +	netif_carrier_off(dev);
> +
>  	return 0;
>  

You should do this before the network device is registered.
