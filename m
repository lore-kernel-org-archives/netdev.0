From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 3/7] net: delete excess kernel-doc notation
Date: Wed, 29 Oct 2008 22:34:58 -0700
Message-ID: <20081029223458.d5295690.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@linux-foundation.org>, davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet14.oracle.com ([148.87.113.126]:35979 "EHLO
	rgminet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754969AbYJ3Fh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 01:37:27 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rgminet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id m9U5bjZL025034
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 05:37:46 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Remove excess kernel-doc function parameters from networking header
& driver files:

Warning(include/net/sock.h:946): Excess function parameter or struct member 'sk' description in 'sk_filter_release'
Warning(include/linux/netdevice.h:1545): Excess function parameter or struct member 'cpu' description in 'netif_tx_lock'
Warning(drivers/net/wan/z85230.c:712): Excess function parameter or struct member 'regs' description in 'z8530_interrupt'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/wan/z85230.c  |    1 -
 include/linux/netdevice.h |    1 -
 include/net/sock.h        |    1 -
 3 files changed, 3 deletions(-)

--- lin2628-rc2.orig/include/linux/netdevice.h
+++ lin2628-rc2/include/linux/netdevice.h
@@ -1537,7 +1537,6 @@ static inline void __netif_tx_unlock_bh(
 /**
  *	netif_tx_lock - grab network device transmit lock
  *	@dev: network device
- *	@cpu: cpu number of lock owner
  *
  * Get network device transmit lock
  */
--- lin2628-rc2.orig/include/net/sock.h
+++ lin2628-rc2/include/net/sock.h
@@ -936,7 +936,6 @@ extern void sock_init_data(struct socket
 
 /**
  *	sk_filter_release: Release a socket filter
- *	@sk: socket
  *	@fp: filter to remove
  *
  *	Remove a filter from a socket and release its resources.
--- lin2628-rc2.orig/drivers/net/wan/z85230.c
+++ lin2628-rc2/drivers/net/wan/z85230.c
@@ -695,7 +695,6 @@ EXPORT_SYMBOL(z8530_nop);
  *	z8530_interrupt - Handle an interrupt from a Z8530
  *	@irq: 	Interrupt number
  *	@dev_id: The Z8530 device that is interrupting.
- *	@regs: unused
  *
  *	A Z85[2]30 device has stuck its hand in the air for attention.
  *	We scan both the channels on the chip for events and then call
