From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 06/43] drivers/net/lance.c: fix sparse warnings: fix signedness
Date: Sat, 14 Feb 2009 22:13:24 +0100
Message-ID: <20090214211257.23489.76477.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:34276 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbZBNVNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:13:30 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Besides from fixing the signedness issue remove some
whitespace to obey to the 80 character limit.

Fix this sparse warnings:
  drivers/net/lance.c:399:19: warning: incorrect type in assignment (different signedness)
  drivers/net/lance.c:654:29: warning: incorrect type in argument 2 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/lance.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index d7afb93..d83d401 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -391,7 +391,8 @@ MODULE_LICENSE("GPL");
    */
 static int __init do_lance_probe(struct net_device *dev)
 {
-	int *port, result;
+	unsigned int *port;
+	int result;
 
 	if (high_memory <= phys_to_virt(16*1024*1024))
 		lance_need_isa_bounce_buffers = 0;
@@ -456,13 +457,13 @@ out:
 static int __init lance_probe1(struct net_device *dev, int ioaddr, int irq, int options)
 {
 	struct lance_private *lp;
-	long dma_channels;			/* Mark spuriously-busy DMA channels */
+	unsigned long dma_channels;	/* Mark spuriously-busy DMA channels */
 	int i, reset_val, lance_version;
 	const char *chipname;
 	/* Flags for specific chips or boards. */
-	unsigned char hpJ2405A = 0;		/* HP ISA adaptor */
-	int hp_builtin = 0;			/* HP on-board ethernet. */
-	static int did_version;			/* Already printed version info. */
+	unsigned char hpJ2405A = 0;	/* HP ISA adaptor */
+	int hp_builtin = 0;		/* HP on-board ethernet. */
+	static int did_version;		/* Already printed version info. */
 	unsigned long flags;
 	int err = -ENOMEM;
 	void __iomem *bios;

