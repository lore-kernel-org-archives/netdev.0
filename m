From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] Remove long-dead commented-out MODULE_PARM reference.
Date: Sun, 27 May 2007 14:02:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0705271401170.9645@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:39802 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbXE0SDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 14:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove the useless comment referring to the obsolete MODULE_PARM
macro.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index abe9b08..2351092 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -111,7 +111,6 @@ MODULE_AUTHOR("Myson or whoever");
 MODULE_DESCRIPTION("Myson MTD-8xx 100/10M Ethernet PCI Adapter Driver");
 MODULE_LICENSE("GPL");
 module_param(max_interrupt_work, int, 0);
-//MODULE_PARM(min_pci_latency, "i");
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param(multicast_filter_limit, int, 0);
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
