From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH 1/2] net: dcbnl: remove redundant DCB_CAP_DCBX_STATIC
	bit
Date: Fri, 21 Jan 2011 18:35:13 -0800
Message-ID: <20110122023512.4239.40379.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54264 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387Ab1AVCkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 21:40:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant DCB_CAP_DCBX_STATIC bit in DCB capabilities

Setting this bit indicates that no embedded DCBx engine is
present and the hardware can not be configured. This is the
same as having none of the DCB capability flags set or simply
not implementing the dcbnl ops at all.

This patch removes this bit. The bit has not made a stable
release yet so removing it should not be an issue with
existing apps.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
CC: Shmulik Ravid <shmulikr@broadcom.com>
---

 include/linux/dcbnl.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 68cd248..ac9df34 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -423,18 +423,11 @@ enum dcbnl_cap_attrs {
  *
  * @DCB_CAP_DCBX_VER_IEEE: for a non-host DCBX engine, indicates the engine
  *                         supports the IEEE protocol flavor
- *
- * @DCB_CAP_DCBX_STATIC: for a non-host DCBX engine, indicates the engine
- *                       supports static configuration (i.e no actual
- *                       negotiation is performed negotiated parameters equal
- *                       the initial configuration)
- *
  */
 #define DCB_CAP_DCBX_HOST		0x01
 #define DCB_CAP_DCBX_LLD_MANAGED	0x02
 #define DCB_CAP_DCBX_VER_CEE		0x04
 #define DCB_CAP_DCBX_VER_IEEE		0x08
-#define DCB_CAP_DCBX_STATIC		0x10
 
 /**
  * enum dcbnl_numtcs_attrs - number of traffic classes

