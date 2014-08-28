From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 4/4] include/rxrpc/types.h: Remove unused header
Date: Thu, 28 Aug 2014 13:44:34 +0200
Message-ID: <1409226274-3202-5-git-send-email-linux@rasmusvillemoes.dk>
References: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The header file include/rxrpc/types.h does not seem to be used
anywhere. It was orphaned by 63b6be55 "[AF_RXRPC]: Delete the old
RxRPC code.". Remove it.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/rxrpc/types.h | 41 -----------------------------------------
 1 file changed, 41 deletions(-)
 delete mode 100644 include/rxrpc/types.h

diff --git a/include/rxrpc/types.h b/include/rxrpc/types.h
deleted file mode 100644
index 30d48f6..0000000
--- a/include/rxrpc/types.h
+++ /dev/null
@@ -1,41 +0,0 @@
-/* types.h: Rx types
- *
- * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-
-#ifndef _LINUX_RXRPC_TYPES_H
-#define _LINUX_RXRPC_TYPES_H
-
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/spinlock.h>
-#include <linux/atomic.h>
-
-typedef uint32_t	rxrpc_seq_t;	/* Rx message sequence number */
-typedef uint32_t	rxrpc_serial_t;	/* Rx message serial number */
-typedef __be32	rxrpc_seq_net_t; /* on-the-wire Rx message sequence number */
-typedef __be32	rxrpc_serial_net_t; /* on-the-wire Rx message serial number */
-
-struct rxrpc_call;
-struct rxrpc_connection;
-struct rxrpc_header;
-struct rxrpc_message;
-struct rxrpc_operation;
-struct rxrpc_peer;
-struct rxrpc_service;
-typedef struct rxrpc_timer rxrpc_timer_t;
-struct rxrpc_transport;
-
-typedef void (*rxrpc_call_attn_func_t)(struct rxrpc_call *call);
-typedef void (*rxrpc_call_error_func_t)(struct rxrpc_call *call);
-typedef void (*rxrpc_call_aemap_func_t)(struct rxrpc_call *call);
-
-#endif /* _LINUX_RXRPC_TYPES_H */
-- 
2.0.4
