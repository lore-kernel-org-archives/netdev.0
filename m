From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] net: pcmcia/axnet_cs: includecheck fix axnet_cs.c
Date: Sun, 09 Aug 2009 18:35:25 +0530
Message-ID: <1249823125.2957.6.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	David Hinds <dahinds@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:41992 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753723AbZHINHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 09:07:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fix the following 'make includecheck' warning:

  drivers/net/pcmcia/axnet_cs.c: linux/etherdevice.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/pcmcia/axnet_cs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index b5cfac7..1e87d63 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -893,8 +893,6 @@ static const char version_8390[] = KERN_INFO \
 #include <linux/in.h>
 #include <linux/interrupt.h>
 
-#include <linux/etherdevice.h>
-
 #define BUG_83C690
 
 /* These are the operational function interfaces to board-specific
-- 
1.6.0.6



