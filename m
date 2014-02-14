From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 11/14] i40e: remove unnecessary delay
Date: Fri, 14 Feb 2014 14:58:05 -0800
Message-ID: <1392418688-23895-12-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23819 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162AbaBNXB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:27 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Ain't nothing gonna break my stride, nobody's gonna slow me down,
oh no. I got to keep on moving.

This was originally put in for debugging just-in-case purposes
and never removed.

Change-ID: Ic12c2e179c3923f54e6ba0a9e4ab05d25c3bab29
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 7d133fa..189e250 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -671,7 +671,6 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 complete_reset:
 	/* reallocate vf resources to reset the VSI state */
 	i40e_free_vf_res(vf);
-	mdelay(10);
 	i40e_alloc_vf_res(vf);
 	i40e_enable_vf_mappings(vf);
 	set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
-- 
1.8.5.GIT
