From: Kumar Gala <galak@gate.crashing.org>
Subject: [PATCH] gfar: fix compile error
Date: Thu, 5 Jan 2006 09:41:59 -0600 (CST)
Message-ID: <Pine.LNX.4.44.0601050941160.31237-100000@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-kernel@vger.kernel.org>,
	<afleming@freescale.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751430AbWAEPr6@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Missing include of <linux/in.h> to get definition of IPPROTO_UDP.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

---
commit 1a6720f78a7fb69451983e6b73723b57594ecac1
tree c8772f20a27fd82d28e78c342782297afb35c580
parent 7b5d230825fc228414dce7dc2bfdace4ecea4613
author Kumar Gala <galak@kernel.crashing.org> Thu, 05 Jan 2006 09:45:05 -0600
committer Kumar Gala <galak@kernel.crashing.org> Thu, 05 Jan 2006 09:45:05 -0600

 drivers/net/gianfar.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 146f951..637b73a 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -84,6 +84,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
+#include <linux/in.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
