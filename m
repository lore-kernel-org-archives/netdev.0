From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/8] dcbnl: Add netlink attributes for setapp/getapp
	to dcbnl
Date: Mon, 31 Aug 2009 15:33:20 -0700
Message-ID: <20090831223319.30995.236.stgit@localhost.localdomain>
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
	by vger.kernel.org with ESMTP id S1752142AbZHaWdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:33:36 -0400
In-Reply-To: <20090831223110.30995.61162.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add defines for dcbnl netlink attributes to support netlink message passing of
setapp/getapp in dcbnl.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/dcb/dcbnl.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 8379496..4046468 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -64,6 +64,7 @@ static struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_CAP]         = {.type = NLA_NESTED},
 	[DCB_ATTR_PFC_STATE]   = {.type = NLA_U8},
 	[DCB_ATTR_BCN]         = {.type = NLA_NESTED},
+	[DCB_ATTR_APP]         = {.type = NLA_NESTED},
 };
 
 /* DCB priority flow control to User Priority nested attributes */
@@ -158,6 +159,13 @@ static struct nla_policy dcbnl_bcn_nest[DCB_BCN_ATTR_MAX + 1] = {
 	[DCB_BCN_ATTR_ALL]          = {.type = NLA_FLAG},
 };
 
+/* DCB APP nested attributes. */
+static struct nla_policy dcbnl_app_nest[DCB_APP_ATTR_MAX + 1] = {
+	[DCB_APP_ATTR_IDTYPE]       = {.type = NLA_U8},
+	[DCB_APP_ATTR_ID]           = {.type = NLA_U16},
+	[DCB_APP_ATTR_PRIORITY]     = {.type = NLA_U8},
+};
+
 /* standard netlink reply call */
 static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
                        u32 seq, u16 flags)

