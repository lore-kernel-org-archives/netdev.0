From: Dave Jones <davej@redhat.com>
Subject: Remove useless comment from sb1250
Date: Wed, 18 Oct 2006 00:30:27 -0400
Message-ID: <20061018043026.GA7533@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:16022 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751364AbWJREa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 00:30:28 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k9I4USPA004232
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 00:30:28 -0400
Received: from nwo.kernelslacker.org (vpn-248-4.boston.redhat.com [10.13.248.4])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9I4URYS018250
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 00:30:27 -0400
Received: from nwo.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by nwo.kernelslacker.org (8.13.8/8.13.7) with ESMTP id k9I4URNT007545
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 00:30:27 -0400
Received: (from davej@localhost)
	by nwo.kernelslacker.org (8.13.8/8.13.8/Submit) id k9I4UR1C007544
	for netdev@vger.kernel.org; Wed, 18 Oct 2006 00:30:27 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index db23249..1eae16b 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2903,7 +2903,7 @@ #endif
 
 		dev = alloc_etherdev(sizeof(struct sbmac_softc));
 		if (!dev)
-			return -ENOMEM;	/* return ENOMEM */
+			return -ENOMEM;
 
 		printk(KERN_DEBUG "sbmac: configuring MAC at %lx\n", port);
 

-- 
http://www.codemonkey.org.uk
