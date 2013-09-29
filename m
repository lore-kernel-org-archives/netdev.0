From: David Miller <davem@davemloft.net>
Subject: Re: [ipv4:PATCH] Allow userspace to specify primary or secondary
 ip on interface
Date: Sun, 29 Sep 2013 17:59:36 -0400 (EDT)
Message-ID: <20130929.175936.607666065014569193.davem@davemloft.net>
References: <1380056988-6717-1-git-send-email-vincent.mc.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vincent.mc.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864Ab3I2V7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 17:59:41 -0400
In-Reply-To: <1380056988-6717-1-git-send-email-vincent.mc.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Li <vincent.mc.li@gmail.com>
Date: Tue, 24 Sep 2013 14:09:48 -0700

> the reason for this patch is that we have a multi blade cluster platform 
> sharing 'floating management ip' and also that each blade has its own 
> management ip on the management interface, so whichever blade in the
> cluster becomes primary blade, the 'floating mangaement ip' follows it,
> and we want any of our traffic originated from the primary blade source from
> the 'floating management ip' for consistency. but in this case, since the local
> blade management ip is always the primary ip on the mangaement interface and 
> 'floating management ip' is always secondary, kernel always choose the primary
> ip as source ip address. thus we would like to add the flexibility in kernel to
> allow us to specify which ip to be primary or secondary.

You have the flexibility already.

You can specify a specific source address ot use in routes.
