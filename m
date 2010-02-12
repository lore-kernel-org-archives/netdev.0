From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPv6: keep permanent addresses on admin down
Date: Fri, 12 Feb 2010 12:30:21 -0800 (PST)
Message-ID: <20100212.123021.228309529.davem@davemloft.net>
References: <20100208214805.1f8f2c6d@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52552
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757678Ab0BLUaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:30:06 -0500
In-Reply-To: <20100208214805.1f8f2c6d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 8 Feb 2010 21:48:05 -0800

> Permanent IPV6 addresses should not be removed when the link is
> set to admin down, only when device is removed. 
> 
> When link is lost permanent addresses should be marked as tentative
> so that when link comes back they are subject to duplicate address
> detection (if DAD was enabled for that address).
> 
> Other routing systems keep manually configured IPv6 addresses
> when link is set down.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
