From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH 03/17] Net: can: Makefile: Remove deprecated kbuild goal definitions
Date: Sun, 21 Nov 2010 20:03:14 -0500
Message-ID: <1290387808-2239-4-git-send-email-tdent48227@gmail.com>
References: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Cc: marcel@holtmann.org, padovan@profusion.mobi,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	sjur.brandeland@stericsson.com, socketcan@hartkopp.net,
	urs.thuermann@volkswagen.de, socketcan-core@lists.berlios.de,
	sage@newdream.net, ceph-devel@vger.kernel.org,
	wang840925@gmail.com, jlayton@redhat.com, kaber@trash.net,
	pekkas@netcore.fi, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	samuel@sortiz.org, Tracey Dent <tdent48227@gmail.com>
To: davem@davemloft.net
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed Makefile to use <modules>-y instead of <modules>-objs
because -objs is deprecated and not mentioned in
Documentation/kbuild/makefiles.txt.

Signed-off-by: Tracey Dent <tdent48227@gmail.com>
---
 net/can/Makefile |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/can/Makefile b/net/can/Makefile
index 9cd3c4b..2d3894b 100644
--- a/net/can/Makefile
+++ b/net/can/Makefile
@@ -3,10 +3,10 @@
 #
 
 obj-$(CONFIG_CAN)	+= can.o
-can-objs		:= af_can.o proc.o
+can-y			:= af_can.o proc.o
 
 obj-$(CONFIG_CAN_RAW)	+= can-raw.o
-can-raw-objs		:= raw.o
+can-raw-y		:= raw.o
 
 obj-$(CONFIG_CAN_BCM)	+= can-bcm.o
-can-bcm-objs		:= bcm.o
+can-bcm-y		:= bcm.o
-- 
1.7.3.2.245.g03276

