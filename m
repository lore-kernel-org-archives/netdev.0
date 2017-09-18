From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] vsock: vmci: Remove unneeded linux/miscdevice.h include
Date: Mon, 18 Sep 2017 20:18:55 +0200
Message-ID: <20170918181855.32211-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/vmw_vsock/vmci_transport.c does not use any miscdevice so this patch
remove this unnecessary inclusion.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 net/vmw_vsock/vmci_transport.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 10ae7823a19d..0206155bff53 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -21,7 +21,6 @@
 #include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <linux/list.h>
-#include <linux/miscdevice.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/net.h>
-- 
2.13.5
