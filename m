From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 4/9] i40evf: remove unnecessary break after goto
Date: Sat, 12 Jul 2014 20:09:43 +0200
Message-ID: <1405188597-2815-5-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:13940 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbaGLSLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2014 14:11:30 -0400
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7fc5f3b..7195566 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2006,7 +2006,6 @@ static void i40evf_init_task(struct work_struct *work)
 		}
 		adapter->state = __I40EVF_INIT_VERSION_CHECK;
 		goto restart;
-		break;
 	case __I40EVF_INIT_VERSION_CHECK:
 		if (!i40evf_asq_done(hw)) {
 			dev_err(&pdev->dev, "Admin queue command never completed\n");
@@ -2028,7 +2027,6 @@ static void i40evf_init_task(struct work_struct *work)
 		}
 		adapter->state = __I40EVF_INIT_GET_RESOURCES;
 		goto restart;
-		break;
 	case __I40EVF_INIT_GET_RESOURCES:
 		/* aq msg sent, awaiting reply */
 		if (!adapter->vf_res) {
-- 
1.9.1
