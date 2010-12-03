From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: optimize INET input path further
Date: Fri, 03 Dec 2010 09:11:59 -0800 (PST)
Message-ID: <20101203.091159.70180198.davem@davemloft.net>
References: <4CF687F3.7030107@hp.com>
	<1291225358.2856.1035.camel@edumazet-laptop>
	<4CF68D35.8020701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751628Ab0LCRLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:11:32 -0500
In-Reply-To: <4CF68D35.8020701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 01 Dec 2010 13:00:21 -0500

> Yes, all that IPv4 address baggage is still there in an IPv6 sock, even
> if not used.  I haven't even looked close enough to see if it is possible
> to move the IPv6 addresses since I think there are times when both are
> in-use.

Both need to be there and can be active at the same time.
IPV4 mapped sockets and how we handle them kill all the
posibility share the struct space consumed by these addresses.
