From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] change bridge sysctl tunables to __read_mostly
Date: Fri, 01 Sep 2006 11:31:43 -0400
Message-ID: <44F8525F.9050403@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070204000409050001040907"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:10642 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751560AbWIAPbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 11:31:47 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070204000409050001040907
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change some bridge sysctl tunables to __read_mostly.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------070204000409050001040907
Content-Type: text/x-patch;
 name="bridge.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bridge.patch"

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index cf80dd0..ac181be 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -53,10 +53,10 @@
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
-static int brnf_call_iptables = 1;
-static int brnf_call_ip6tables = 1;
-static int brnf_call_arptables = 1;
-static int brnf_filter_vlan_tagged = 1;
+static int brnf_call_iptables __read_mostly = 1;
+static int brnf_call_ip6tables __read_mostly = 1;
+static int brnf_call_arptables __read_mostly = 1;
+static int brnf_filter_vlan_tagged __read_mostly = 1;
 #else
 #define brnf_filter_vlan_tagged 1
 #endif

--------------070204000409050001040907--
