From: David Miller <davem@davemloft.net>
Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Wed, 18 Nov 2009 10:24:34 -0800 (PST)
Message-ID: <20091118.102434.160976750.davem@davemloft.net>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C56894@HQ-EXCH-7.corp.brocade.com>
	<20091117.231706.125598146.davem@davemloft.net>
	<D67825C5985D0647BE40A5F5B0B70D1106E9C568F1@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jharan@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932327AbZKRSYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:24:17 -0500
In-Reply-To: <D67825C5985D0647BE40A5F5B0B70D1106E9C568F1@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Haran <jharan@Brocade.COM>
Date: Wed, 18 Nov 2009 10:22:54 -0800

> So is this a bug or a feature?

It definitely seems intentional.

> When I call setsockopt() to set this option on a NETLINK socket,
> setsockopt() appears to return 0 to indicate success. If it's not
> going to be supported, shouldn't setsockopt() return -1 with
> ENOPROTOOPT in errno in this case?

There are a lot of socket option values that can be set but which
are not used by the protocol in question.

I don't think any changes need to be made.
