From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Fri, 21 Mar 2008 15:47:28 -0700 (PDT)
Message-ID: <20080321.154728.263190239.davem@davemloft.net>
References: <20080321110515.422f9798@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762601AbYCUWrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:47:13 -0400
In-Reply-To: <20080321110515.422f9798@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Mar 2008 11:05:15 -0700

> Make socket filters work for netlink unicast and notifications.
> This is useful for applications like Zebra that get overrun with
> messages that are then ignored.
> 
> Note: netlink messages are in host byte order, but packet filter
> state machine operations are done as network byte order.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.

Although we will have to, at some point, address the
issue of how to transfer netlink on-the-wire portably
and how that interacts with the existing userland
interfaces.

