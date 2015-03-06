From: Fan Du <fan.du@intel.com>
Subject: [PATCHv5 net-next 4/4] ipv4: Documenting two sysctls for tcp PMTU probe
Date: Fri,  6 Mar 2015 11:18:25 +0800
Message-ID: <1425611905-28503-5-git-send-email-fan.du@intel.com>
References: <1425611905-28503-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:38531 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753985AbbCFDXY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 22:23:24 -0500
In-Reply-To: <1425611905-28503-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Namely tcp_probe_interval to control how often to restart
a probe. And tcp_probe_threshold to control when stop the
probing in respect to the width of search range in bytes

Signed-off-by: Fan Du <fan.du@intel.com>
---
 Documentation/networking/ip-sysctl.txt |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1b8c964..4412f69 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -388,6 +388,16 @@ tcp_mtu_probing - INTEGER
 	  1 - Disabled by default, enabled when an ICMP black hole detected
 	  2 - Always enabled, use initial MSS of tcp_base_mss.
 
+tcp_probe_interval - INTEGER
+	Controls how often to start TCP Packetization-Layer Path MTU
+	Discovery reprobe. The default is reprobing every 10 minutes as
+	per RFC4821.
+
+tcp_probe_threshold - INTEGER
+	Controls when TCP Packetization-Layer Path MTU Discovery probing
+	will stop in respect to the width of search range in bytes. Default
+	is 8 bytes.
+
 tcp_no_metrics_save - BOOLEAN
 	By default, TCP saves various connection metrics in the route cache
 	when the connection closes, so that connections established in the
-- 
1.7.1
