From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/9] ixgb: fix interface losing macaddr on ifdn/up
Date: Fri, 26 May 2006 09:51:58 -0700
Message-ID: <20060526165158.30514.69611.stgit@gitlost.site>
References: <20060526165124.30514.78477.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
        "Kok, Auke" <auke-jan.h.kok@intel.com>,
        "Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:28934 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751126AbWEZQqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 12:46:54 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060526165124.30514.78477.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


user contributed fix for LAA across down/up, from tonychung00@users.sf.net.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 954894b..26c777f 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -238,6 +238,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 	/* hardware has been reset, we need to reload some things */
 
+	ixgb_rar_set(hw, netdev->dev_addr, 0);
 	ixgb_set_multi(netdev);
 
 	ixgb_restore_vlan(adapter);



--
Auke Kok <auke-jan.h.kok@intel.com>
