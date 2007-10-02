From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 02 Oct 2007 15:04:38 -0700 (PDT)
Message-ID: <20071002.150438.78357233.davem@davemloft.net>
References: <20071002142016.GE7881@ghostprotocols.net>
	<4702B1FD.70102@hartkopp.net>
	<20071002145236.3818bd63@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, acme@ghostprotocols.net,
	urs@isnogud.escape.de, netdev@vger.kernel.org, kaber@trash.net,
	tglx@linutronix.de, yoshfuji@linux-ipv6.org, ebiederm@xmission.com,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753942AbXJBWEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 18:04:38 -0400
In-Reply-To: <20071002145236.3818bd63@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 2 Oct 2007 14:52:36 -0700

> Please consider using netif_msg_xxx() and module parameter to set
> default message level, like other real network drivers already do.

I keep seeing this recommendation, but the two supposedly most mature
and actively used drivers in the tree, tg3 and e1000 and e1000e, all
do not use this scheme.

In fact there are tons of drivers that even hook up the ethtool
msg_level setting function and never even use the value.

If people aren't using netif_msg_xxx() and the ethtool msg_level
facilities properly, it's because there is a severe dearth of good
example drivers to learn about it from.
