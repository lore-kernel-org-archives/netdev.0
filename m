From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] lmc header file not needed
Date: Mon, 5 Apr 2004 16:29:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405162908.68e5aff4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Domen Puncer <domen@coderock.org>


---

 linux-265-kj1-rddunlap/drivers/net/wan/lmc/lmc_proto.c |    1 -
 linux-265-kj1/drivers/net/wan/lmc/lmc_proto_raw.h      |    4 ----
 2 files changed, 5 deletions(-)

diff -puN drivers/net/wan/lmc/lmc_proto.c~lmc_proto_raw_h_rm drivers/net/wan/lmc/lmc_proto.c
--- linux-265-kj1/drivers/net/wan/lmc/lmc_proto.c~lmc_proto_raw_h_rm	2004-04-05 13:06:33.000000000 -0700
+++ linux-265-kj1-rddunlap/drivers/net/wan/lmc/lmc_proto.c	2004-04-05 13:06:33.000000000 -0700
@@ -50,7 +50,6 @@
 #include "lmc_debug.h"
 #include "lmc_ioctl.h"
 #include "lmc_proto.h"
-//#include "lmc_proto_raw.h"
 
 /*
  * The compile-time variable SPPPSTUP causes the module to be
diff -puN -L drivers/net/wan/lmc/lmc_proto_raw.h drivers/net/wan/lmc/lmc_proto_raw.h~lmc_proto_raw_h_rm /dev/null
--- linux-265-kj1/drivers/net/wan/lmc/lmc_proto_raw.h
+++ /dev/null	2003-05-01 16:55:24.000000000 -0700
@@ -1,4 +0,0 @@
-#ifndef _LMC_PROTO_RAW_H_
-#define _LMC_PROTO_RAW_H_
-
-#endif

_


--
~Randy
"We have met the enemy and he is us."  -- Pogo (by Walt Kelly)
