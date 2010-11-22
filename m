From: Tracey Dent <tdent48227@gmail.com>
Subject: [PATCH 09/17] Net: irda: ircomm: Makefile: Remove deprecated kbuild goal defintions
Date: Sun, 21 Nov 2010 20:03:20 -0500
Message-ID: <1290387808-2239-10-git-send-email-tdent48227@gmail.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290387808-2239-1-git-send-email-tdent48227@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed Makefile to use <modules>-y instead of <modules>-objs
because -objs is deprecated and not mentioned in
Documentation/kbuild/makefiles.txt.

Signed-off-by: Tracey Dent <tdent48227@gmail.com>
---
 net/irda/ircomm/Makefile |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/irda/ircomm/Makefile b/net/irda/ircomm/Makefile
index 4868945..ab23b5b 100644
--- a/net/irda/ircomm/Makefile
+++ b/net/irda/ircomm/Makefile
@@ -4,5 +4,5 @@
 
 obj-$(CONFIG_IRCOMM) += ircomm.o ircomm-tty.o
 
-ircomm-objs := ircomm_core.o ircomm_event.o ircomm_lmp.o ircomm_ttp.o
-ircomm-tty-objs := ircomm_tty.o ircomm_tty_attach.o ircomm_tty_ioctl.o ircomm_param.o
+ircomm-y := ircomm_core.o ircomm_event.o ircomm_lmp.o ircomm_ttp.o
+ircomm-tty-y := ircomm_tty.o ircomm_tty_attach.o ircomm_tty_ioctl.o ircomm_param.o
-- 
1.7.3.2.245.g03276

