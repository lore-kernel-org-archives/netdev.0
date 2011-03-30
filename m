From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/2] atm/solos-pci: Use VPI.VCI notation uniformly.
Date: Wed, 30 Mar 2011 17:22:45 -0600
Message-ID: <1301527365-28995-1-git-send-email-philipp_subx@redfish-solutions.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:39287 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753826Ab1C3XWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 19:22:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip A. Prindeville <philipp@redfish-solutions.com>

Use VPI.VCI notation consistently throughout the module. This is the
one remaining place where the VCI is used before the VPI in any output.

Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
---
 drivers/atm/solos-pci.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 25ef1a4..2c4146a 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -710,8 +710,8 @@ void solos_bh(unsigned long card_arg)
 					       le16_to_cpu(header->vci));
 				if (!vcc) {
 					if (net_ratelimit())
-						dev_warn(&card->dev->dev, "Received packet for unknown VCI.VPI %d.%d on port %d\n",
-							 le16_to_cpu(header->vci), le16_to_cpu(header->vpi),
+						dev_warn(&card->dev->dev, "Received packet for unknown VPI.VCI %d.%d on port %d\n",
+							 le16_to_cpu(header->vpi), le16_to_cpu(header->vci),
 							 port);
 					continue;
 				}
-- 
1.7.4

