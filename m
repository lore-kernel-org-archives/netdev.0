From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2] net: add doc for ip_early_demux sysctl
Date: Tue, 11 Jun 2013 18:54:39 +0800
Message-ID: <1370948079-26598-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752530Ab3FKKzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 06:55:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

commit 6648bd7e0e62c0c8c03b (ipv4: Add sysctl knob to control
early socket demux) introduced such sysctl, but forgot to add
doc into Documentation/networking/ip-sysctl.txt. This patch adds it.

Basically I grab the doc from the description of commit 41063e9dd11956f2d285
(ipv4: Early TCP socket demux.) and the above commit.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
v2: change based on David's comments

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 9cea5d3..36e5a40 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -685,6 +685,15 @@ ip_dynaddr - BOOLEAN
 	occurs.
 	Default: 0
 
+ip_early_demux - BOOLEAN
+	Optimize input packet processing down to one demux for
+	certain kinds of local sockets.  Currently we only do this
+	for established TCP sockets.
+
+	It may add an additional cost for pure routing workloads that
+	reduces overall throughput, in such case you should disable it.
+	Default: 1
+
 icmp_echo_ignore_all - BOOLEAN
 	If set non-zero, then the kernel will ignore all ICMP ECHO
 	requests sent to it.
