From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH 40/44] includecheck fix: include/linux, net_dropmon.h
Date: Wed, 08 Jul 2009 21:24:16 +0530
Message-ID: <1247068456.4382.104.camel@ht.satnam>
References: <1247063308.4382.12.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:53291 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759260AbZGHQG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2009 12:06:28 -0400
In-Reply-To: <1247063308.4382.12.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fix the following 'make includecheck' warning:

  include/linux/net_dropmon.h: linux/types.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 include/linux/net_dropmon.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.h
index 3ceb0cc..2a73946 100644
--- a/include/linux/net_dropmon.h
+++ b/include/linux/net_dropmon.h
@@ -3,7 +3,6 @@
 
 #include <linux/types.h>
 #include <linux/netlink.h>
-#include <linux/types.h>
 
 struct net_dm_drop_point {
 	__u8 pc[8];
-- 
1.6.0.6



