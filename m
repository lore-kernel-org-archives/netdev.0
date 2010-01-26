From: David Miller <davem@davemloft.net>
Subject: Re: Netlink usage question (for bonding comm with userspace)
Date: Mon, 25 Jan 2010 18:03:57 -0800 (PST)
Message-ID: <20100125.180357.109302552.davem@davemloft.net>
References: <15914.1264466901@death.nxdomain.ibm.com>
	<20100125.165152.132891922.davem@davemloft.net>
	<19462.1264468440@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36223
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396Ab0AZCDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 21:03:46 -0500
In-Reply-To: <19462.1264468440@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 25 Jan 2010 17:14:00 -0800

> 	Just so I'm clear, though: use generic netlink for the needs of
> this particular project, and then later it's acceptable to have both
> generic and rtnetlink co-existing for their respective uses?

Use generic netlink for everything.

It's just a different namespace ("text strings", vs. fixed integer
IDs) for netlink sockets, nothing more really.
