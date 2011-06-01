From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] de2104x: use speed defines instead of number
Date: Wed,  1 Jun 2011 16:14:37 +0200
Message-ID: <1306937677-11101-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751Ab1FAOOl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 10:14:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/tulip/de2104x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index e2f6923..1cc426d 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1507,7 +1507,7 @@ static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 		break;
 	}
 
-	ethtool_cmd_speed_set(ecmd, 10);
+	ethtool_cmd_speed_set(ecmd, SPEED_10);
 
 	if (dr32(MacMode) & FullDuplex)
 		ecmd->duplex = DUPLEX_FULL;
@@ -1529,7 +1529,7 @@ static int __de_set_settings(struct de_private *de, struct ethtool_cmd *ecmd)
 	u32 new_media;
 	unsigned int media_lock;
 
-	if (ethtool_cmd_speed(ecmd) != 10)
+	if (ethtool_cmd_speed(ecmd) != SPEED_10)
 		return -EINVAL;
 	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 		return -EINVAL;
-- 
1.7.4.4

