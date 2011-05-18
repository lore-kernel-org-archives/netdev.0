From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: add notification over netlink when
 STP changes state
Date: Wed, 18 May 2011 18:10:42 -0400 (EDT)
Message-ID: <20110518.181042.1332278156476011677.davem@davemloft.net>
References: <20110518081718.0b1fc390@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab1ERWKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:10:51 -0400
In-Reply-To: <20110518081718.0b1fc390@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 May 2011 08:17:18 -0700

> The first netlink code in the bridge module was to notify
> user space implementations of Spanning Tree Protocol about
> new ports. It did not handle the case of kernel mode STP 
> changing states which could be useful for monitoring.
> 
> This patch causes RTM_NEWLINK message to occur on kernel
> transitions. It does not send message if request was from user
> space STP, since that would cause reflection and break existing
> API.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I agree with Ben that hiding events in any way is going to
be a severe limitation, long term.

I do not want to apply this and keep going down this road.

Sorry.
