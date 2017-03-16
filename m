From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/5] ipvs: Document sysctl sync_ports
Date: Thu, 16 Mar 2017 13:43:14 +0100
Message-ID: <1489668195-15240-5-git-send-email-horms@verge.net.au>
References: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>,
        Hangbin Liu <liuhangbin@gmail.com>,
        Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60914 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdCPMnf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 08:43:35 -0400
In-Reply-To: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>

Document sysctl sync_ports based on commit f73181c8288f ("ipvs: add support
for sync threads").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 159d70b6dff3..a6feecd467cd 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -231,6 +231,14 @@ sync_sock_size - INTEGER
 	Configuration of SNDBUF (master) or RCVBUF (slave) socket limit.
 	Default value is 0 (preserve system defaults).
 
+sync_ports - INTEGER
+	default 1
+
+	The number of threads that master and backup servers can use for
+	sync traffic. Every thread will use single UDP port, thread 0 will
+	use the default port 8848 while last thread will use port
+	8848+sync_ports-1.
+
 snat_reroute - BOOLEAN
 	0 - disabled
 	not 0 - enabled (default)
-- 
2.7.0.rc3.207.g0ac5344
