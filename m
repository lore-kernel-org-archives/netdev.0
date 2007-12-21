From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH] net: santize headers for iproute2
Date: Fri, 21 Dec 2007 09:43:36 -0800
Message-ID: <20071221094336.63600b8c@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60371 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbXLUSLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 13:11:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2 source uses headers that result from "make headers_install".
The header files net/tcp_states.h and net/veth.h are both being used
but are not processed. 

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

---
This patch is not "urgent" but it would be good to get it in 2.6.24.

--- a/include/Kbuild	2007-12-21 09:33:36.000000000 -0800
+++ b/include/Kbuild	2007-12-21 09:33:42.000000000 -0800
@@ -4,5 +4,6 @@ header-y += sound/
 header-y += mtd/
 header-y += rdma/
 header-y += video/
+header-y += net/
 
 header-y += asm-$(ARCH)/
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/include/net/Kbuild	2007-12-21 09:32:20.000000000 -0800
@@ -0,0 +1,2 @@
+header-y += tcp_states.h
+header-y += veth.h
