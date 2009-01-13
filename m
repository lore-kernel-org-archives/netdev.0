From: Jaswinder Singh Rajput <jaswinder@infradead.org>
Subject: [PATCH -tip] in6.h: extern's make no sense in userspace
Date: Tue, 13 Jan 2009 12:27:39 +0530
Message-ID: <1231829859.3212.19.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, sam@ravnborg.org,
	harvey.harrison@gmail.com, gorcunov@gmail.com, roque@di.fc.ul.pt,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60747 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbZAMHAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:00:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: fix 2 make headers_check warnings:

 usr/include/linux/in6.h:47: extern's make no sense in userspace
 usr/include/linux/in6.h:49: extern's make no sense in userspace

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 include/linux/in6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/in6.h b/include/linux/in6.h
index bc49204..718bf21 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -44,11 +44,11 @@ struct in6_addr
  * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
  * in network byte order, not in host byte order as are the IPv4 equivalents
  */
+#ifdef __KERNEL__
 extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
 extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
-#ifdef __KERNEL__
 extern const struct in6_addr in6addr_linklocal_allnodes;
 #define IN6ADDR_LINKLOCAL_ALLNODES_INIT	\
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
-- 
1.5.6.6



