From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] crush: include header for global symbols
Date: Tue, 24 Apr 2012 17:38:37 -0700
Message-ID: <201204241738.38280.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <ceph-devel@vger.kernel.org>,
	<sage@newdream.net>, <davem@davemloft.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <ceph-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include the header to pickup the definitions of the global symbols.

Quiets the following sparse warnings:

warning: symbol 'crush_find_rule' was not declared. Should it be static?
warning: symbol 'crush_do_rule' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Sage Weil <sage@newdream.net>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/net/ceph/crush/mapper.c b/net/ceph/crush/mapper.c
index 854ac53..363f8f7 100644
--- a/net/ceph/crush/mapper.c
+++ b/net/ceph/crush/mapper.c
@@ -20,6 +20,7 @@
 
 #include <linux/crush/crush.h>
 #include <linux/crush/hash.h>
+#include <linux/crush/mapper.h>
 
 /*
  * Implement the core CRUSH mapping algorithm.
