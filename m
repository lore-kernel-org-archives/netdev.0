From: David Miller <davem@davemloft.net>
Subject: Re: Netlink usage question (for bonding comm with userspace)
Date: Mon, 25 Jan 2010 16:51:52 -0800 (PST)
Message-ID: <20100125.165152.132891922.davem@davemloft.net>
References: <15914.1264466901@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751549Ab0AZAvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 19:51:42 -0500
In-Reply-To: <15914.1264466901@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 25 Jan 2010 16:48:21 -0800

> 	I could, for this project, use a netlink_kernel_create and
> socket(AF_NETLINK) pair to perform the communication (presumably adding
> a NETLINK_BONDING or the like to <linux/netlink.h>).

This is no longer done, so that we don't have an issue with
running out of netlink sub-protocol numbers.

Instead use generic netlink, the IDs are allocated dynamically
and looked up via text strings which provides a better scheme
for namespace allocation.
