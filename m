From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc911x: make smsc911x_ethtool_ops constant
Date: Fri, 19 Dec 2008 14:24:06 +0000
Message-ID: <1229696646-13666-2-git-send-email-steve.glendinning@smsc.com>
References: <1229696646-13666-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60626 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753010AbYLSOYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 09:24:05 -0500
In-Reply-To: <1229696646-13666-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 9e33d9f..16d9e19 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1717,7 +1717,7 @@ static int smsc911x_ethtool_set_eeprom(struct net_device *dev,
 	return ret;
 }
 
-static struct ethtool_ops smsc911x_ethtool_ops = {
+static const struct ethtool_ops smsc911x_ethtool_ops = {
 	.get_settings = smsc911x_ethtool_getsettings,
 	.set_settings = smsc911x_ethtool_setsettings,
 	.get_link = ethtool_op_get_link,
-- 
1.6.0.4

