From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH net-next 2/2] net: doc: add default value for neighbour parameters
Date: Wed, 05 Dec 2012 12:50:35 +0800
Message-ID: <50BED29B.4050805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>, Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62636 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab2LEEun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 23:50:43 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so3363300pbc.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 20:50:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 Documentation/networking/ip-sysctl.txt |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c6d5fee..0462a71 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -30,16 +30,24 @@ neigh/default/gc_thresh3 - INTEGER
 	Maximum number of neighbor entries allowed.  Increase this
 	when using large numbers of interfaces and when communicating
 	with large numbers of directly-connected peers.
+	Default: 1024
 
 neigh/default/unres_qlen_bytes - INTEGER
 	The maximum number of bytes which may be used by packets
 	queued for each	unresolved address by other network layers.
 	(added in linux 3.3)
+	Seting negative value is meaningless and will retrun error.
+	Default: 65536 Bytes(64KB)
 
 neigh/default/unres_qlen - INTEGER
 	The maximum number of packets which may be queued for each
 	unresolved address by other network layers.
 	(deprecated in linux 3.3) : use unres_qlen_bytes instead.
+	Prior to linux 3.3, the default value is 3 which may cause
+	secluded packet loss. The current default value is calculated
+	according to default value of unres_qlen_bytes and true size of
+	packet.
+	Default: 31
 
 mtu_expires - INTEGER
 	Time, in seconds, that cached PMTU information is kept.
-- 
1.7.1
