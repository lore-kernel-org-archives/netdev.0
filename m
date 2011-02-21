From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: [PATCH] CAN: add controller hardware name for Softing cards
Date: Mon, 21 Feb 2011 10:04:22 +0100
Message-ID: <20110221090421.GF328@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:7653 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752234Ab1BUJEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 04:04:25 -0500
Received: from e-circ.dyndns.org (unknown [192.168.0.66])
	by e-circ.dyndns.org (Postfix) with ESMTP id B13388A93A
	for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 10:04:20 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just found that the controller hardware name is not set for the Softing
driver. After this patch, "$ ip -d link show" looks nicer.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
---
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 5157e15..aeea9f9 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -633,6 +633,7 @@ static const struct net_device_ops softing_netdev_ops = {
 };
 
 static const struct can_bittiming_const softing_btr_const = {
+	.name = "softing",
 	.tseg1_min = 1,
 	.tseg1_max = 16,
 	.tseg2_min = 1,
