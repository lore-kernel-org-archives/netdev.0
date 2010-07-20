From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: add suspend/resume in the ic+
Date: Tue, 20 Jul 2010 09:12:34 +0200
Message-ID: <1279609954-30274-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:58941 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751648Ab0GTHnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 03:43:47 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8732F74
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 07:12:40 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 113FD191B
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 07:12:39 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 439adaf..3f2583f 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -116,6 +116,8 @@ static struct phy_driver ip175c_driver = {
 	.config_init	= &ip175c_config_init,
 	.config_aneg	= &ip175c_config_aneg,
 	.read_status	= &ip175c_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
-- 
1.5.5.6

