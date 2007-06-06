From: Dave Jones <davej@redhat.com>
Subject: Remove incorrect comment from hamradio/scc.
Date: Wed, 6 Jun 2007 03:03:27 -0400
Message-ID: <20070606070327.GA29312@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759007AbXFFHDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 03:03:42 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l5673fWj032044
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 03:03:41 -0400
Received: from gelk.kernelslacker.org (vpn-248-11.boston.redhat.com [10.13.248.11])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l5673aAt001470
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 03:03:39 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.1/8.13.8) with ESMTP id l5673VZY029329
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 03:03:31 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.1/8.14.1/Submit) id l5673RM9029328
	for netdev@vger.kernel.org; Wed, 6 Jun 2007 03:03:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

scc_rxint doesn't call this function at all.
http://bugzilla.kernel.org/show_bug.cgi?id=8146

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 6fdaad5..30bed2a 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1610,7 +1610,7 @@ static int scc_net_close(struct net_device *dev)
 	return 0;
 }
 
-/* ----> receive frame, called from scc_rxint() <---- */
+/* ----> receive frame <---- */
 
 static void scc_net_rx(struct scc_channel *scc, struct sk_buff *skb)
 {

-- 
http://www.codemonkey.org.uk
