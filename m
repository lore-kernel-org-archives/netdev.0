From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 3/7] enic: Add new firmware devcmds
Date: Tue, 10 Aug 2010 21:55:05 -0700
Message-ID: <20100811045505.3877.24652.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:9745 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab0HKEzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:55:06 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

Add new firmware devcmds:  CMD_PROXY_BY_INDEX, CMD_CONFIG_INFO_GET

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/vnic_devcmd.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)


diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index 2066175..9abb3d5 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -238,6 +238,18 @@ enum vnic_devcmd_cmd {
 	 * out: (u32)a0=status of proxied cmd
 	 *      a1-a15=out args of proxied cmd */
 	CMD_PROXY_BY_BDF =	_CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 42),
+
+	/*
+	 * As for BY_BDF except a0 is index of hvnlink subordinate vnic
+	 * or SR-IOV virtual vnic */
+	CMD_PROXY_BY_INDEX =    _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 43),
+
+	/*
+	 * in:  (u64)a0=paddr of buffer to put latest VIC VIF-CONFIG-INFO TLV in
+	 *      (u32)a1=length of buffer in a0
+	 * out: (u64)a0=paddr of buffer with latest VIC VIF-CONFIG-INFO TLV
+	 *      (u32)a1=actual length of latest VIC VIF-CONFIG-INFO TLV */
+	CMD_CONFIG_INFO_GET     = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 44),
 };
 
 /* flags for CMD_OPEN */

