From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] NFC: remove commented out Makefile line
Date: Sun, 12 May 2013 23:21:24 +0200
Message-ID: <1368393684.1350.16.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-nfc@lists.01.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Kconfig symbol NFC_LLCP was removed in commit 30cc458765 ("NFC: Move
LLCP code to the NFC top level diirectory"). But the reference to its
macro in this Makefile was only commented out. Remove it now.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Untested.

 net/nfc/Makefile | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/nfc/Makefile b/net/nfc/Makefile
index fb799de..a76f453 100644
--- a/net/nfc/Makefile
+++ b/net/nfc/Makefile
@@ -5,7 +5,6 @@
 obj-$(CONFIG_NFC) += nfc.o
 obj-$(CONFIG_NFC_NCI) += nci/
 obj-$(CONFIG_NFC_HCI) += hci/
-#obj-$(CONFIG_NFC_LLCP) += llcp/
 
 nfc-objs := core.o netlink.o af_nfc.o rawsock.o llcp_core.o llcp_commands.o \
 		llcp_sock.o
-- 
1.7.11.7
