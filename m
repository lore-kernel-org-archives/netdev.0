From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] genetlink: remove ops_list from genetlink header.
Date: Sun,  4 Jun 2017 10:07:41 +0300
Message-ID: <1496560061-1673-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, johannes.berg@intel.com,
        Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43803 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751159AbdFDONK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 10:13:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d91824 ("genetlink: register family ops as array") removed the 
ops_list member from both genl_family and genl_ops; while the 
documentation of genl_family was updated accordingly by this patch, 
ops_list remained in the documentation of the genl_ops object. 
This patch fixes it by removing ops_list from genl_ops documentation. 

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 include/net/genetlink.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 68b8819..c59a098 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -128,7 +128,6 @@ static inline int genl_err_attr(struct genl_info *info, int err,
  * @start: start callback for dumps
  * @dumpit: callback for dumpers
  * @done: completion callback for dumps
- * @ops_list: operations list
  */
 struct genl_ops {
 	const struct nla_policy	*policy;
-- 
2.4.11
