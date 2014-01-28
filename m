From: Dave Jones <davej@redhat.com>
Subject: i40e: Add missing braces to i40e_dcb_need_reconfig()
Date: Mon, 27 Jan 2014 23:11:09 -0500
Message-ID: <20140128041109.GA25771@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neerav.Parikh@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbaA1ELU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 23:11:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indentation mismatch spotted with Coverity.
Introduced in 4e3b35b044ea ("i40e: add DCB and DCBNL support")
 
Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a4b940862b83..b901371ca361 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4440,9 +4440,10 @@ bool i40e_dcb_need_reconfig(struct i40e_pf *pf,
 	/* Check if APP Table has changed */
 	if (memcmp(&new_cfg->app,
 		   &old_cfg->app,
-		   sizeof(new_cfg->app)))
+		   sizeof(new_cfg->app))) {
 		need_reconfig = true;
 		dev_info(&pf->pdev->dev, "APP Table change detected.\n");
+	}
 
 	return need_reconfig;
 }
