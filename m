From: Dave Jones <davej@redhat.com>
Subject: typo in via-velocity.c
Date: Wed, 6 Jun 2007 03:07:52 -0400
Message-ID: <20070606070752.GA30437@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbXFFHIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 03:08:00 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l5677xvL001468
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 03:07:59 -0400
Received: from gelk.kernelslacker.org (vpn-248-11.boston.redhat.com [10.13.248.11])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l5677tXk002509
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 03:07:57 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.1/8.13.8) with ESMTP id l5677rt7030446
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 03:07:53 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.1/8.14.1/Submit) id l5677qDS030445
	for netdev@vger.kernel.org; Wed, 6 Jun 2007 03:07:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://bugzilla.kernel.org/show_bug.cgi?id=8160

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 25b75b6..b670b97 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1562,7 +1562,7 @@ static void velocity_print_link_status(struct velocity_info *vptr)
 	if (vptr->mii_status & VELOCITY_LINK_FAIL) {
 		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: failed to detect cable link\n", vptr->dev->name);
 	} else if (vptr->options.spd_dpx == SPD_DPX_AUTO) {
-		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link autonegation", vptr->dev->name);
+		VELOCITY_PRT(MSG_LEVEL_INFO, KERN_NOTICE "%s: Link auto-negotiation", vptr->dev->name);
 
 		if (vptr->mii_status & VELOCITY_SPEED_1000)
 			VELOCITY_PRT(MSG_LEVEL_INFO, " speed 1000M bps");

-- 
http://www.codemonkey.org.uk
