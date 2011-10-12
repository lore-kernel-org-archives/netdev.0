From: Phil Edworthy <phil.edworthy@renesas.com>
Subject: [PATCH] smsc911x: Add support for SMSC LAN89218
Date: Wed, 12 Oct 2011 13:29:39 +0100
Message-ID: <1318422579-26243-1-git-send-email-phil.edworthy@renesas.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	Phil Edworthy <phil.edworthy@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:44686 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab1JLMaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 08:30:19 -0400
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0LSY005DXDEH0V50@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 12 Oct 2011 21:30:17 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0LSY00991DEHRS10@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 12 Oct 2011 21:30:17 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LAN89218 is register compatible with LAN911x.

Signed-off-by: Phil Edworthy <phil.edworthy@renesas.com>
---
 drivers/net/smsc911x.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index b9016a3..c90ddb6 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -26,6 +26,7 @@
  *   LAN9215, LAN9216, LAN9217, LAN9218
  *   LAN9210, LAN9211
  *   LAN9220, LAN9221
+ *   LAN89218
  *
  */
 
@@ -1983,6 +1984,7 @@ static int __devinit smsc911x_init(struct net_device *dev)
 	case 0x01170000:
 	case 0x01160000:
 	case 0x01150000:
+	case 0x218A0000:
 		/* LAN911[5678] family */
 		pdata->generation = pdata->idrev & 0x0000FFFF;
 		break;
-- 
1.7.0.4
