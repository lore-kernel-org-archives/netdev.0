From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH net-next] net: flow_dissector.c missing include
 linux/export.h
Date: Tue, 24 Jan 2012 16:57:23 +0100
Message-ID: <1327420643.4549.113.camel@probook>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56361 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab2AXP5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 10:57:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The file net/core/flow_dissector.c seems to be missing
including linux/export.h.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
 net/core/flow_dissector.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0985b9b..a225089 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -1,4 +1,5 @@
 #include <linux/skbuff.h>
+#include <linux/export.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/if_vlan.h>
-- 
1.7.2.5
