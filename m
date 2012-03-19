From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH] net: update the usage of CHECKSUM_UNNECESSARY
Date: Mon, 19 Mar 2012 14:12:41 -0700
Message-ID: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: devel@open-fcoe.org, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821Ab2CSUzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 16:55:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Ben, this adds the clarification on the usage of
CHECKSUM_UNNECESSARY on the outgoing patch. Also add the usage
description of NETIF_F_FCOE_CRC and CHECKSUM_UNNECESSARY
for the kernel FCoE protocol driver.

This is a follow-up to the following:
http://patchwork.ozlabs.org/patch/147315/

Signed-off-by: Yi Zou <yi.zou@intel.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: www.Open-FCoE.org <devel@open-fcoe.org>
---

 include/linux/skbuff.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8dc8257..a2b9953 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -94,6 +94,13 @@
  *			  about CHECKSUM_UNNECESSARY. 8)
  *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
  *
+ *	UNNECESSARY: device will do per protocol specific csum. Protocol drivers
+ *	that do not want net to perform the checksum calculation should use
+ *	this flag in their outgoing skbs.
+ *	NETIF_F_FCOE_CRC  this indicates the device can do FCoE FC CRC
+ *			  offload. Correspondingly, the FCoE protocol driver
+ *			  stack should use CHECKSUM_UNNECESSARY.
+ *
  *	Any questions? No questions, good. 		--ANK
  */
 
