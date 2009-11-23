From: Gregory Haskins <ghaskins@novell.com>
Subject: [-next PATCH 2/4] venet: add missing ethtool include
Date: Mon, 23 Nov 2009 14:54:39 -0500
Message-ID: <20091123195439.8184.70167.stgit@dev.haskins.net>
References: <20091123195136.8184.68042.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: linux-next@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756565AbZKWTyl@vger.kernel.org>
In-Reply-To: <20091123195136.8184.68042.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's sloppy to use the facility without officially including its header
file.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/net/vbus-enet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vbus-enet.c b/drivers/net/vbus-enet.c
index 29b388f..25c6bea 100644
--- a/drivers/net/vbus-enet.c
+++ b/drivers/net/vbus-enet.c
@@ -22,6 +22,7 @@
 #include <linux/in.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/skbuff.h>
