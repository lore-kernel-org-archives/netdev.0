From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] net/Makefile: conditionally descend to wireless and
 ieee802154
Date: Sun, 27 Jun 2010 12:00:25 +0200
Message-ID: <20100627120025.0232a9d0@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kbuild@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't descend to wireless and ieee802154 unless they are actually used.

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 net/Makefile |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/Makefile b/net/Makefile
index cb7bdc1..41d4200 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -50,7 +50,7 @@ endif
 obj-$(CONFIG_IP_DCCP)		+= dccp/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
 obj-$(CONFIG_RDS)		+= rds/
-obj-y				+= wireless/
+obj-$(CONFIG_WIRELESS)		+= wireless/
 obj-$(CONFIG_MAC80211)		+= mac80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
@@ -61,7 +61,7 @@ obj-$(CONFIG_CAIF)		+= caif/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
-obj-y				+= ieee802154/
+obj-$(CONFIG_IEEE802154)	+= ieee802154/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
-- 
1.7.1
