From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] netpoll: remove CONFIG_NETPOLL_RX
Date: Sat, 28 Apr 2007 22:48:52 +0400
Message-ID: <200704282248.52072.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:41745 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031228AbXD1SrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 14:47:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of the CONFIG_NETPOLL_RX option completely since all the dependencies
have been removed long ago...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
See commit e3c265bcf67f21d847e970e71504890f61f37824 in tglx/history.git for the
patch that removed the #ifdef's.

 drivers/net/Kconfig       |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -2928,11 +2928,6 @@ endif #NETDEVICES
 config NETPOLL
 	def_bool NETCONSOLE
 
-config NETPOLL_RX
-	bool "Netpoll support for trapping incoming packets"
-	default n
-	depends on NETPOLL
-
 config NETPOLL_TRAP
 	bool "Netpoll traffic trapping"
 	default n

