From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 1/2] solos-pci: Use VPI.VCI notation consistently throughout
 module
Date: Sun, 27 Mar 2011 23:56:13 -0700
Message-ID: <4D90310D.5000601@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Nathan Williams <nathan@traverse.com.au>,
	Karl Hiramoto <karl@hiramoto.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60922 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818Ab1C1G7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 02:59:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp@redfish-solutions.com>

Use VPI.VCI notation consistently throughout the module. This is the one remaining place where the VCI
is used before the VPI in any output.

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


