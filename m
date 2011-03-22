From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH v2 1/1] Use VPI.VCI notation consistently in solos-pci driver
Date: Tue, 22 Mar 2011 15:33:36 -0700
Message-ID: <4D8923C0.505@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:56465 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752653Ab1CVWdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 18:33:43 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local ([192.55.64.189])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2MMXaiv028174
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 16:33:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use VPI/VCI notation consistently.

Signed-off-by: Philip Prindeville<philipp@redfish-solutions.com>
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


