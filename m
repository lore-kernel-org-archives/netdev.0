From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/1] Use VPI.VCI notation consistently in solos-pci driver
Date: Sun, 26 Dec 2010 11:09:05 -0800
Message-ID: <4D1792D1.4040803@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:57170 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752393Ab0LZTJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Dec 2010 14:09:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use VPI.VCI notation consistently.

Signed-of-by: Philip Prindeville<philipp@redfish-solutions.com>
---

--- a/drivers/atm/solos-pci-0.11/solos-pci.c	2010-12-24 01:07:09.000000000 -0700
+++ b/drivers/atm/solos-pci-0.11/solos-pci.c	2010-12-24 14:18:45.000000000 -0700
@@ -734,8 +734,8 @@ void solos_bh(unsigned long card_arg)
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


