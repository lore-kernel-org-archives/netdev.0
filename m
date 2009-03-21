From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/30] solos: Handle attribute show/store in kernel
 more sanely
Date: Sat, 21 Mar 2009 13:22:39 -0700 (PDT)
Message-ID: <20090321.132239.74116822.davem@davemloft.net>
References: <1237325355.27681.335.camel@macbook.infradead.org>
	<20090317154411.598b9f00@nehalam>
	<1237330172.27829.14.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752605AbZCUUWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:22:52 -0400
In-Reply-To: <1237330172.27829.14.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Tue, 17 Mar 2009 22:49:32 +0000

> On Tue, 2009-03-17 at 15:44 -0700, Stephen Hemminger wrote:
> > Since these are generic, please use some form of netlink for this
> > instead of sysfs.
> > 
> > Bonding was the first mistake (trying to use sysfs for a transactional
> > API).
> > Pls don't repeat the mistake.
> 
> It's not a transactional API.
> 
> The sysfs model actually fits the communication with the hardware almost
> perfectly -- there are a bunch of named parameters, all of which can be
> read and a few of which can be written to. A sysfs read or write
> translates directly into a single exchange with the device's firmware.

Fair enough, I'll pull this into net-next-2.6
