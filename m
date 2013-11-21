From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] wimax: remove dead code
Date: Thu, 21 Nov 2013 04:43:11 +0100
Message-ID: <1385005391-18379-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56224 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751501Ab3KUDnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 22:43:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes a code line that is between a "return 0;" and an error label.
This code line can never be reached.

Found by Coverity (CID: 1130529)

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 net/wimax/stack.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index ef2191b969a7..ec8b577db135 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -610,7 +610,6 @@ int __init wimax_subsys_init(void)
 	d_fnend(4, NULL, "() = 0\n");
 	return 0;
 
-	genl_unregister_family(&wimax_gnl_family);
 error_register_family:
 	d_fnend(4, NULL, "() = %d\n", result);
 	return result;
-- 
1.8.3.2
