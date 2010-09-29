From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip_gre: lockless xmit
Date: Wed, 29 Sep 2010 01:21:20 -0700 (PDT)
Message-ID: <20100929.012120.260091648.davem@davemloft.net>
References: <1285664747.2607.48.camel@edumazet-laptop>
	<4CA2F46B.1070607@6wind.com>
	<1285748288.2615.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754816Ab0I2IVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:21:00 -0400
In-Reply-To: <1285748288.2615.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Sep 2010 10:18:08 +0200

> What is deprecated is to assert NETIF_F_LLTX and yet, use a lock in the
> ndo_xmit() driver method.

Also we've discussed recently to do away with the NETIF_F_LLTX
flag entirely for queue-less devices such as loopback and
sw tunnels.

Then all will be left are the truly "deprecated" cases Eric
mentions.
