From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/2] solos-pci: Use VPI.VCI notation consistently throughout
 module
Date: Sun, 27 Mar 2011 22:18:52 -0700
Message-ID: <4D901A3C.5040709@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60454 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751459Ab1C1FTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 01:19:00 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local (pool-71-111-146-59.ptldor.dsl-w.verizon.net [71.111.146.59])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2S5IqUH019199
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 23:18:59 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     Use VPI.VCI notation consistently.

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


