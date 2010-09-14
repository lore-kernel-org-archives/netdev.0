From: Joe Perches <joe@perches.com>
Subject: [PATCH next 08/16] drivers/net/pcmcia: Use static const char * const where possible
Date: Mon, 13 Sep 2010 21:23:54 -0700
Message-ID: <603371a64a6b701d23c9ab55f9887aaddaef57f3.1284435710.git.joe@perches.com>
References: <cover.1284435709.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1995 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab0INEYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 00:24:15 -0400
In-Reply-To: <cover.1284435709.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcmcia/3c589_cs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 7f2baf5..35562a3 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -266,7 +266,7 @@ static int tc589_config(struct pcmcia_device *link)
     __be16 *phys_addr;
     int ret, i, j, multi = 0, fifo;
     unsigned int ioaddr;
-    char *ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
+    static const char * const ram_split[] = {"5:3", "3:1", "1:1", "3:5"};
     u8 *buf;
     size_t len;
 
-- 
1.7.3.rc1

