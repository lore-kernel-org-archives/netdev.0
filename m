From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 10/39] fealnx: stop using
 net_device.{base_addr, irq}.
Date: Fri, 06 Apr 2012 06:21:47 -0400 (EDT)
Message-ID: <20120406.062147.2000030375239361962.davem@davemloft.net>
References: <1333704408.git.romieu@fr.zoreil.com>
	<7db239c57d31d1d3fdc73e22b27ed9c46fc1da65.1333704409.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab2DFKWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 06:22:51 -0400
In-Reply-To: <7db239c57d31d1d3fdc73e22b27ed9c46fc1da65.1333704409.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri,  6 Apr 2012 12:06:24 +0200

> -	if (request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev))
> -		return -EAGAIN;
> +	rc = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
> +	if (rc < 0)
> +		goto out;

Please at least preserve the test, make it "if (rc)"
