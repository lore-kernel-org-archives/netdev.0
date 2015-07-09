From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: systemport: Use eth_hw_addr_random
Date: Thu, 09 Jul 2015 14:51:36 -0700 (PDT)
Message-ID: <20150709.145136.29434262043413419.davem@davemloft.net>
References: <20150708051930.GA13317@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162AbbGIVvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 17:51:37 -0400
In-Reply-To: <20150708051930.GA13317@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Wed, 8 Jul 2015 10:49:30 +0530

> Use eth_hw_addr_random() instead of calling random_ether_addr().
> Here, this change is setting addr_assign_type to NET_ADDR_RANDOM.
> 
> The Coccinelle semantic patch that performs this transformation
> is as follows:
> 
> @@
> identifier a,b;
> @@
> 
> -random_ether_addr(a->b);
> +eth_hw_addr_random(a);
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied, thanks.
