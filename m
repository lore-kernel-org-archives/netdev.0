From: Max Matveev <makc@redhat.com>
Subject: [PATCH v2 2/2] Update documented default values for various TCP/UDP tunables
Date: Wed, 22 Jun 2011 17:18:13 +1000
Message-ID: <20110705015729.91CD5815DBB1@regina.usersys.redhat.com>
Cc: netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46276 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab1GEB5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 21:57:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_rmem and tcp_wmem use 1 page as default value for the minimum
amount of memory to be used, same as udp_wmem_min and udp_rmem_min.
Pages are different size on different architectures - use the right
units when describing the defaults.

Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Max Matveev <makc@redhat.com>
---
 Documentation/networking/ip-sysctl.txt |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ce09f83..940a404 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -394,7 +394,7 @@ tcp_rmem - vector of 3 INTEGERs: min, default, max
 	min: Minimal size of receive buffer used by TCP sockets.
 	It is guaranteed to each TCP socket, even under moderate memory
 	pressure.
-	Default: 8K
+	Default: 1 page
 
 	default: initial size of receive buffer used by TCP sockets.
 	This value overrides net.core.rmem_default used by other protocols.
@@ -483,7 +483,7 @@ tcp_window_scaling - BOOLEAN
 tcp_wmem - vector of 3 INTEGERs: min, default, max
 	min: Amount of memory reserved for send buffers for TCP sockets.
 	Each TCP socket has rights to use it due to fact of its birth.
-	Default: 4K
+	Default: 1 page
 
 	default: initial size of send buffer used by TCP sockets.  This
 	value overrides net.core.wmem_default used by other protocols.
@@ -553,13 +553,13 @@ udp_rmem_min - INTEGER
 	Minimal size of receive buffer used by UDP sockets in moderation.
 	Each UDP socket is able to use the size for receiving data, even if
 	total pages of UDP sockets exceed udp_mem pressure. The unit is byte.
-	Default: 4096
+	Default: 1 page
 
 udp_wmem_min - INTEGER
 	Minimal size of send buffer used by UDP sockets in moderation.
 	Each UDP socket is able to use the size for sending data, even if
 	total pages of UDP sockets exceed udp_mem pressure. The unit is byte.
-	Default: 4096
+	Default: 1 page
 
 CIPSOv4 Variables:
 
-- 
1.7.3.3

