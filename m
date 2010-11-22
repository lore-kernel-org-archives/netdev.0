From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH 12/17] Net: lapb: Makefile: Remove deprecated kbuild goal definitions
Date: Sun, 21 Nov 2010 20:03:23 -0500
Message-ID: <1290387808-2239-13-git-send-email-tdent48227@gmail.com>
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
 net/lapb/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/lapb/Makefile b/net/lapb/Makefile
index 53f7c90..fff797d 100644
--- a/net/lapb/Makefile
+++ b/net/lapb/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_LAPB) += lapb.o
 
-lapb-objs := lapb_in.o lapb_out.o lapb_subr.o lapb_timer.o lapb_iface.o
+lapb-y := lapb_in.o lapb_out.o lapb_subr.o lapb_timer.o lapb_iface.o
-- 
1.7.3.2.245.g03276

