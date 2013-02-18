From: Andy King <acking@vmware.com>
Subject: [PATCH 2/4] VSOCK: get rid of vsock_version.h
Date: Mon, 18 Feb 2013 08:04:11 -0800
Message-ID: <1361203453-1347-3-git-send-email-acking@vmware.com>
References: <1361203453-1347-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Dmitry Torokhov <dtor@vmware.com>,
	davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1361203453-1347-1-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dtor@vmware.com>

There isn't really a need to have a separate file for it.

Acked-by: Andy King <acking@vmware.com>
Signed-off-by: Dmitry Torokhov <dtor@vmware.com>
---
 net/vmw_vsock/af_vsock.c      |    3 +--
 net/vmw_vsock/vsock_version.h |   22 ----------------------
 2 files changed, 1 insertions(+), 24 deletions(-)
 delete mode 100644 net/vmw_vsock/vsock_version.h

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index a8efe5a..c1b9e55 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -98,7 +98,6 @@
 #include <net/sock.h>
 
 #include "af_vsock.h"
-#include "vsock_version.h"
 
 static int __vsock_bind(struct sock *sk, struct sockaddr_vm *addr);
 static void vsock_sk_destruct(struct sock *sk);
@@ -2009,5 +2008,5 @@ EXPORT_SYMBOL_GPL(vsock_core_exit);
 
 MODULE_AUTHOR("VMware, Inc.");
 MODULE_DESCRIPTION("VMware Virtual Socket Family");
-MODULE_VERSION(VSOCK_DRIVER_VERSION_STRING);
+MODULE_VERSION("1.0.0.0-k");
 MODULE_LICENSE("GPL v2");
diff --git a/net/vmw_vsock/vsock_version.h b/net/vmw_vsock/vsock_version.h
deleted file mode 100644
index 4df7f5e..0000000
--- a/net/vmw_vsock/vsock_version.h
+++ /dev/null
@@ -1,22 +0,0 @@
-/*
- * VMware vSockets Driver
- *
- * Copyright (C) 2011-2012 VMware, Inc. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License as published by the Free
- * Software Foundation version 2 and no later version.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- */
-
-#ifndef _VSOCK_VERSION_H_
-#define _VSOCK_VERSION_H_
-
-#define VSOCK_DRIVER_VERSION_PARTS	{ 1, 0, 0, 0 }
-#define VSOCK_DRIVER_VERSION_STRING	"1.0.0.0-k"
-
-#endif /* _VSOCK_VERSION_H_ */
-- 
1.7.4.1
