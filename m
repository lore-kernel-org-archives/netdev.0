From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: [PATCH 3/4] irda: New device ID for nsc-ircc
Date: Mon, 30 Jun 2008 21:23:54 +0200
Message-ID: <20080630192754.283576823@sortiz.org>
References: <20080630192351.765611690@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Ville Syrjala <syrjala@sci.fi>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.29]:28026 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbYF3T0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 15:26:24 -0400
Content-Disposition: inline; filename=nsc-ircc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ville Syrjala <syrjala@sci.fi>

HP OmniBook 500's DSDT code changes the HID of the FIR device from
NSC6001 to HWPC224 when run under an "NT" operating system. Add the
new ID to the pnp device id table.

Signed-off-by: Ville Syrjala <syrjala@sci.fi>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/nsc-ircc.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-next-2.6/drivers/net/irda/nsc-ircc.c
===================================================================
--- net-next-2.6.orig/drivers/net/irda/nsc-ircc.c	2008-06-14 13:20:23.000000000 +0200
+++ net-next-2.6/drivers/net/irda/nsc-ircc.c	2008-06-30 20:44:23.000000000 +0200
@@ -152,6 +152,7 @@ static chipio_t pnp_info;
 static const struct pnp_device_id nsc_ircc_pnp_table[] = {
 	{ .id = "NSC6001", .driver_data = 0 },
 	{ .id = "IBM0071", .driver_data = 0 },
+	{ .id = "HWPC224", .driver_data = 0 },
 	{ }
 };
 

-- 

