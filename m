From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] i40e: use correct structure type name in sizeof
Date: Tue, 12 Aug 2014 01:38:24 -0700
Message-ID: <1407832707-26034-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48371 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658AbaHLIig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 04:38:36 -0400
In-Reply-To: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 51bc030..2ac8f45 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6293,7 +6293,7 @@ static int i40e_vsi_alloc_arrays(struct i40e_vsi *vsi, bool alloc_qvectors)
 
 	if (alloc_qvectors) {
 		/* allocate memory for q_vector pointers */
-		size = sizeof(struct i40e_q_vectors *) * vsi->num_q_vectors;
+		size = sizeof(struct i40e_q_vector *) * vsi->num_q_vectors;
 		vsi->q_vectors = kzalloc(size, GFP_KERNEL);
 		if (!vsi->q_vectors) {
 			ret = -ENOMEM;
-- 
1.9.3
