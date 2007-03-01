From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 23:22:24 -0800 (PST)
Message-ID: <20070228.232224.74746939.davem@davemloft.net>
References: <20070228195611.24cf19ee@deepthought>
	<45E650F6.4030404@candelatech.com>
	<45E67B04.2060702@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933076AbXCAHWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 02:22:50 -0500
In-Reply-To: <45E67B04.2060702@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 28 Feb 2007 23:04:36 -0800

> If an normal application has to use something like raw packet
> filtering, it seems there is a missing API.

I'm loosely following this discussion, but Ben mentions DHCP
and I remember learning the other month that DHCP uses AF_PACKET
and filtering instead of IP RAW sockets because it needs to get
the MAC address and RAW sockets don't provide that.
