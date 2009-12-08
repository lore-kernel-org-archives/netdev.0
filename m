From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/20] net/atm/addr.c: checkpatch cleanups
Date: Mon,  7 Dec 2009 21:56:58 -0800
Message-ID: <a62cf5386cb8906da411b325c5d4c832731be764.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1041 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932366AbZLHF5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:11 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Includes some or all of these:

Mostly 80 column wrapped.
printk->pr_info and pr_cont
Use print_hex_dump
Use __func__ for embedded print strings
Move embedded assigns out of tests
Move trailing statements to new lines
switch/case cleanups
    removed breaks after returns
Removed paren around returns
Use %pM
Moved leading continuation logical tests to end of previous line

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/addr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/atm/addr.c b/net/atm/addr.c
index 82e85ab..cf3ae8b 100644
--- a/net/atm/addr.c
+++ b/net/atm/addr.c
@@ -4,7 +4,7 @@
 
 #include <linux/atm.h>
 #include <linux/atmdev.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include "signaling.h"
 #include "addr.h"
-- 
1.6.6.rc0.57.gad7a

