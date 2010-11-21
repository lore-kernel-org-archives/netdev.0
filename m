From: Joe Perches <joe@perches.com>
Subject: [PATCH 34/62] pcmcia: Use static const
Date: Sat, 20 Nov 2010 18:38:35 -0800
Message-ID: <1f7d4c6e1fdab36507810e75ef088273b55ca243.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1690 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169Ab0KUCkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:15 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  14697	   1380	   2768	  18845	   499d	drivers/net/pcmcia/nmclan_cs.o.old
  14697	   1380	   2768	  18845	   499d	drivers/net/pcmcia/nmclan_cs.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcmcia/nmclan_cs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
index 0a2b0f9..76683d9 100644
--- a/drivers/net/pcmcia/nmclan_cs.c
+++ b/drivers/net/pcmcia/nmclan_cs.c
@@ -1291,7 +1291,7 @@ updateCRC
 
 static void updateCRC(int *CRC, int bit)
 {
-  int poly[]={
+  static const int poly[]={
     1,1,1,0, 1,1,0,1,
     1,0,1,1, 1,0,0,0,
     1,0,0,0, 0,0,1,1,
-- 
1.7.3.2.245.g03276.dirty

