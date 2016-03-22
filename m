From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 7/8] tc/m_vlan.c: mention CONTROL option in help text
Date: Tue, 22 Mar 2016 15:48:38 +0100
Message-ID: <1458658119-25881-8-git-send-email-phil@nwl.cc>
References: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43737 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932821AbcCVOtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 10:49:10 -0400
In-Reply-To: <1458658119-25881-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_vlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 8d97963f351bc..3233d207375bf 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -22,9 +22,10 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: vlan pop\n");
-	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID\n");
+	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID [CONTROL]\n");
 	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1AD\n");
 	fprintf(stderr, "            with default: 802.1Q\n");
+	fprintf(stderr, "       CONTROL := reclassify | pipe | drop | continue | pass\n");
 }
 
 static void usage(void)
-- 
2.7.2
