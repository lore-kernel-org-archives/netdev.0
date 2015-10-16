From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH iproute2] ip-address: fix oneline mode for interfaces with VF
Date: Fri, 16 Oct 2015 12:34:05 +0200
Message-ID: <1444991645-32062-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Phil@nwl.cc, "Sutter <phil"@nwl.cc
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51088 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828AbbJPKeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 06:34:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index e864ca6..f290205 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -345,7 +345,7 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 	} else
 		vf_linkstate = NULL;
 
-	fprintf(fp, "\n    vf %d MAC %s", vf_mac->vf,
+	fprintf(fp, "%s    vf %d MAC %s", _SL_, vf_mac->vf,
 		ll_addr_n2a((unsigned char *)&vf_mac->mac,
 		ETH_ALEN, 0, b1, sizeof(b1)));
 	if (vf_vlan->vlan)
-- 
2.5.0
