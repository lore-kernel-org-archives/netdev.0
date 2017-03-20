From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/22] ipvs: Document sysctl pmtu_disc
Date: Mon, 20 Mar 2017 11:08:48 +0100
Message-ID: <1490004530-9128-21-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hangbin Liu <liuhangbin@gmail.com>

Document sysctl pmtu_disc based on commit 3654e61137db ("ipvs: add
pmtu_disc option to disable IP DF for TUN packets").

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 Documentation/networking/ipvs-sysctl.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index a6feecd467cd..056898685d40 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -175,6 +175,14 @@ nat_icmp_send - BOOLEAN
         for VS/NAT when the load balancer receives packets from real
         servers but the connection entries don't exist.
 
+pmtu_disc - BOOLEAN
+	0 - disabled
+	not 0 - enabled (default)
+
+	By default, reject with FRAG_NEEDED all DF packets that exceed
+	the PMTU, irrespective of the forwarding method. For TUN method
+	the flag can be disabled to fragment such packets.
+
 secure_tcp - INTEGER
         0  - disabled (default)
 
-- 
2.1.4

