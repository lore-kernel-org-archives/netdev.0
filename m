From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix for adding multicast route for loopback
 device automatically.
Date: Wed, 07 Dec 2011 15:06:15 -0500 (EST)
Message-ID: <20111207.150615.181825066035193136.davem@davemloft.net>
References: <4EDF1481.1080106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757117Ab1LGUHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 15:07:24 -0500
In-Reply-To: <4EDF1481.1080106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Wed, 07 Dec 2011 15:23:45 +0800

> There is no obvious reason to add a default multicast route for loopback
> devices, otherwise there would be a route entry whose dst.error set to
> -ENETUNREACH that would blocking all multicast packets.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

I still do not understand the purpose of this change, what problems
does the current behavior cause?

And can you be sure that by making this change, you are not breaking
something, somewhere, that depends upon the current behavior?
