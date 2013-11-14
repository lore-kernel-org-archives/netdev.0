From: Dave Jones <davej@redhat.com>
Subject: netfilter: ipset: fix incorret comparison in
 hash_netnet4_data_equal()
Date: Thu, 14 Nov 2013 10:41:01 -0500
Message-ID: <20131114154101.GA22625@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab3KNPlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 10:41:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both sides of the comparison are the same, looks like a cut-and-paste error.

Spotted by Coverity.

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 2bc2dec20b00..6226803fc490 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -59,7 +59,7 @@ hash_netnet4_data_equal(const struct hash_netnet4_elem *ip1,
 		     u32 *multi)
 {
 	return ip1->ipcmp == ip2->ipcmp &&
-	       ip2->ccmp == ip2->ccmp;
+	       ip1->ccmp == ip2->ccmp;
 }
 
 static inline int
