From: David Miller <davem@davemloft.net>
Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Wed, 18 Nov 2009 11:09:18 -0800 (PST)
Message-ID: <20091118.110918.154510772.davem@davemloft.net>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C568FE@HQ-EXCH-7.corp.brocade.com>
	<20091118.104434.185425439.davem@davemloft.net>
	<D67825C5985D0647BE40A5F5B0B70D1106E9C5690C@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jharan@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758341AbZKRTJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 14:09:01 -0500
In-Reply-To: <D67825C5985D0647BE40A5F5B0B70D1106E9C5690C@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Haran <jharan@Brocade.COM>
Date: Wed, 18 Nov 2009 11:00:35 -0800

> If the open source community doesn't want a fix for something that
> is obviously broken, that's fine.

It is a bug in your opinion, and adding a check for these cases
doesn't necessarily make the kernel any better.

You can even check BSD, it behaves just like we do for several socket
options (they are just pieces of state stored in the socket, having
protocol specific checks and/or callbacks for every single socket
option would be just a lot of useless bloat).

And when all else fails BSD's behavior is what we use to determine
what is reasonable.
