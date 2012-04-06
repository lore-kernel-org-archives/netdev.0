From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 32/39] epic100: stop using
 net_device.{base_addr, irq} and convert to __iomem.
Date: Fri, 06 Apr 2012 06:25:10 -0400 (EDT)
Message-ID: <20120406.062510.1292136785820320926.davem@davemloft.net>
References: <1333704408.git.romieu@fr.zoreil.com>
	<6b7afbabfb5dc03aca2fea47cae8db27239bb589.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547Ab2DFK0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 06:26:16 -0400
In-Reply-To: <6b7afbabfb5dc03aca2fea47cae8db27239bb589.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri,  6 Apr 2012 12:06:46 +0200

>  	napi_enable(&ep->napi);
> -	if ((retval = request_irq(dev->irq, epic_interrupt, IRQF_SHARED, dev->name, dev))) {
> +	rc = request_irq(irq, epic_interrupt, IRQF_SHARED, dev->name, dev);
> +	if (rc < 0) {

Please preserve the test: "if (rc)"
