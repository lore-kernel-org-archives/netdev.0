From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] NET: fix r8169 linkage
Date: Wed, 10 Sep 2008 14:30:27 +0200
Message-ID: <1221049827-14264-1-git-send-email-jirislaby@gmail.com>
References: <20080909080309.3104a54c.randy.dunlap@oracle.com>
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.advnet.cz ([213.180.51.194]:37600 "EHLO mail1.advnet.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108AbYIJNEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 09:04:55 -0400
In-Reply-To: <20080909080309.3104a54c.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R8169 depends on MII code, thus select MII in Kconfig by R8169.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4c818d5..b0a5a17 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2034,6 +2034,7 @@ config R8169
 	tristate "Realtek 8169 gigabit ethernet support"
 	depends on PCI
 	select CRC32
+	select MII
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
-- 
1.6.0

