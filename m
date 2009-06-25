From: Nicolas Reinecke <nr@das-labor.org>
Subject: [Patch] mdio add missing GPL flag
Date: Thu, 25 Jun 2009 14:55:31 +0200
Message-ID: <1245934531.7828.25.camel@allekto>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vegas.das-labor.org ([80.82.213.127]:59486 "EHLO
	vegas.das-labor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbZFYNB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 09:01:59 -0400
Received: from [IPv6:2001:470:9960:28f1:215:17ff:fe0b:bf62] (unknown [IPv6:2001:470:9960:28f1:215:17ff:fe0b:bf62])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: pl4nkton)
	by vegas.das-labor.org (Postfix) with ESMTPSA id DAC9E9A077
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 14:55:35 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing GPL flag and description.

mdio: module license 'unspecified' taints kernel.
Disabling lock debugging due to kernel taint

Signed-off-by: Nicolas Reinecke <nr <at> das-labor.org> 
---
drivers/net/mdio.c |    5 +++++
1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index dc45e98..09a351c 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -14,6 +14,11 @@
#include <linux/mdio.h>
#include <linux/module.h>

+MODULE_DESCRIPTION("Generic support for MDIO-compatible transceivers");
+MODULE_AUTHOR("Copyright 2006-2009 Solarflare Communications Inc.");
+MODULE_LICENSE("GPL");
+
+
/**
  * mdio45_probe - probe for an MDIO (clause 45) device
  * @mdio: MDIO interface

