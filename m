From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next-2.6 PATCH] remove DCB_PROTO_VERSION as we don't do netlink
	versioning
Date: Thu, 22 Apr 2010 17:38:03 -0700
Message-ID: <20100423003802.29068.29465.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucy.liu@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:31832 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045Ab0DWAiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 20:38:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

remove DCB_PROTO_VERSION as we don't do netlink versioning

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 include/linux/dcbnl.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index b7cdbb4..8723491 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -22,8 +22,6 @@
 
 #include <linux/types.h>
 
-#define DCB_PROTO_VERSION 1
-
 struct dcbmsg {
 	__u8               dcb_family;
 	__u8               cmd;

