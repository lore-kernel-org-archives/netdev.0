From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] net: fix new kernel-doc warnings in net core
Date: Mon, 04 Mar 2013 14:32:43 -0800
Message-ID: <5135210B.6090207@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44007 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643Ab3CDWcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 17:32:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix new kernel-doc warnings in net/core/dev.c:

Warning(net/core/dev.c:4788): No description found for parameter 'new_carrier'
Warning(net/core/dev.c:4788): Excess function parameter 'new_carries' description in 'dev_change_carrier'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-39-rc1.orig/net/core/dev.c
+++ lnx-39-rc1/net/core/dev.c
@@ -4780,7 +4780,7 @@ EXPORT_SYMBOL(dev_set_mac_address);
 /**
  *	dev_change_carrier - Change device carrier
  *	@dev: device
- *	@new_carries: new value
+ *	@new_carrier: new value
  *
  *	Change device carrier
  */
