From: igorm@etf.rs
Subject: [PATCH 01/10 net-next] include: net: netns: mib: Add proc_dir_entry for ipv4 per interface stats
Date: Fri, 16 Dec 2011 16:25:54 +0100
Message-ID: <1324049163-11207-2-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:35773 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759977Ab1LPP0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:16 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Introduces proc_dir_entry in which we will hold ipv4 per interface proc files

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 include/net/netns/mib.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
index d542a4b..eaac2d1 100644
--- a/include/net/netns/mib.h
+++ b/include/net/netns/mib.h
@@ -4,6 +4,7 @@
 #include <net/snmp.h>
 
 struct netns_mib {
+	struct proc_dir_entry *proc_net_devsnmp;
 	DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 	DEFINE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 	DEFINE_SNMP_STAT(struct linux_mib, net_statistics);
-- 
1.7.5.4
