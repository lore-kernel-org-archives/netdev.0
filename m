From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 03 Jun 2008 10:25:01 -0700 (PDT)
Message-ID: <20080603.102501.193702820.davem@davemloft.net>
References: <20080602165347.5662f602@extreme>
	<20080604.011717.77875207.yoshfuji@linux-ipv6.org>
	<20080603102144.571df55b@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753028AbYFCRZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:25:06 -0400
In-Reply-To: <20080603102144.571df55b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 3 Jun 2008 10:21:44 -0700

> The patch just makes carrier_off respond the same as doing 'ip link set dev eth0 down'
> (or ifconfig eth0 down). A router needs to be able to re-route when link fails.

But I can't see how this behavior makes sense for the normal desktop case
and it disagrees with existing practice for many years.

If I pull out my network cable while making some adjustments in my
rack, and then plug it back in, I don't expect to lose my static
routes on that interface.

That doesn't make any sense at all.
