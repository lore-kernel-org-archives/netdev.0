From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited Slow-Start)
Date: Fri, 18 May 2007 19:27:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-74673123-1179505661=:22402"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47172 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755524AbXERQ1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 12:27:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-74673123-1179505661=:22402
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ce16e6a..44ba8d4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -239,6 +239,19 @@ tcp_max_orphans - INTEGER
 	more aggressively. Let me to remind again: each orphan eats
 	up to ~64K of unswappable memory.
 
+tcp_max_ssthresh - INTEGER
+	Limited Slow-Start for TCP with Large Congestion Windows defined in
+	RFC3742. Limited slow-start is a mechanism to limit grow of the
+	congestion window on the region where congestion window is larger than
+	tcp_max_ssthresh. A TCP connection with a large congestion window could
+	have its congestion window increased by thousand (or even more)
+	segments per RTT by the traditional slow-start procedure which might be
+	counter-productive to TCP performance when packet losses start to
+	occur. With limited slow-start TCP increments congestion window at
+	most tcp_max_ssthresh/2 segments per RTT when the congestion window is
+	above tcp_max_ssthresh.
+	Default: 0 (off)
+
 tcp_max_syn_backlog - INTEGER
 	Maximal number of remembered connection requests, which are
 	still did not receive an acknowledgment from connecting client.
-- 
1.5.0.6

---696243703-74673123-1179505661=:22402--
