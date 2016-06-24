From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] caif: Remove unneeded header file
Date: Fri, 24 Jun 2016 11:53:54 +0530
Message-ID: <20160624062354.GA23515@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: dmitry.tarnyagin@lockless.no, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop redundant include of moduleparam.h

The Coccinelle semantic patch used to make this change is as follows:
@ includesmodule @
@@

#include <linux/module.h>

@ depends on includesmodule @
@@

- #include <linux/moduleparam.h>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 net/caif/chnl_net.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 67a4a36..3408ed5 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -13,7 +13,6 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/if_ether.h>
-#include <linux/moduleparam.h>
 #include <linux/ip.h>
 #include <linux/sched.h>
 #include <linux/sockios.h>
-- 
1.9.1
