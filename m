From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 5/5] enic: Fix log message
Date: Wed, 20 Oct 2010 13:17:19 -0700
Message-ID: <20101020201719.26870.79271.stgit@savbu-pc100.cisco.com>
References: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:23689 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755503Ab0JTURT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 16:17:19 -0400
In-Reply-To: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Fix a log message

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a63d2ba..f47fbb6 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2428,7 +2428,7 @@ static int enic_dev_init(struct enic *enic)
 
 	err = enic_dev_set_ig_vlan_rewrite_mode(enic);
 	if (err) {
-		netdev_err(netdev,
+		dev_err(dev,
 			"Failed to set ingress vlan rewrite mode, aborting.\n");
 		goto err_out_free_vnic_resources;
 	}

