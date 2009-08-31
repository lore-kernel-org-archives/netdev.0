From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/8] dcbnl: Add support for setapp/getapp to netdev
	dcbnl_rtnl_ops
Date: Mon, 31 Aug 2009 15:32:55 -0700
Message-ID: <20090831223254.30995.88655.stgit@localhost.localdomain>
References: <20090831223110.30995.61162.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:44148 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbZHaWdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:33:16 -0400
In-Reply-To: <20090831223110.30995.61162.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Adds support of dcbnl setapp/getapp to dcbnl_rtnl_ops in netdev to allow
LLDs to implement their corresponding dcbnl setapp/getapp ops to support
the IEEE 802.1Q DCBX setapp/getapp commands.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/net/dcbnl.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 775cfc8..b36ac7e 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -48,6 +48,8 @@ struct dcbnl_rtnl_ops {
 	void (*setbcncfg)(struct net_device *, int, u32);
 	void (*getbcnrp)(struct net_device *, int, u8 *);
 	void (*setbcnrp)(struct net_device *, int, u8);
+	u8   (*setapp)(struct net_device *, u8, u16, u8);
+	u8   (*getapp)(struct net_device *, u8, u16);
 };
 
 #endif /* __NET_DCBNL_H__ */

