From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: Fixing debug message
Date: Fri, 05 Mar 2010 14:01:29 -0800 (PST)
Message-ID: <20100305.140129.77277949.davem@davemloft.net>
References: <1267735244-8367-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sreenivasa.honnur@neterion.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756075Ab0CEWBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 17:01:10 -0500
In-Reply-To: <1267735244-8367-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Thu,  4 Mar 2010 15:40:44 -0500

> Currently s2io is dumping debug messages using the interface name
> before it was allocated, showing a message like the following:
> 
> s2io: eth%d: Ring Mem PHY: 0x7ef80000
> s2io: s2io_reset: Resetting XFrame card eth%d
> 
> This patch just fixes it, printing the pci bus information for
> the card instead of the interface name.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.

The netdev_*() printing macros we now have in linux/netdev.h
allow to handle these cases transparently btw.
