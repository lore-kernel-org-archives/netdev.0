From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1135/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:26 +0800
Message-ID: <20160802121926.25783-1-baolex.ni@intel.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aryabinin@virtuozzo.com
To: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	kaber@trash.net, kadlec@blackhole.kfki.hu,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19406 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965829AbcHBM5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/sctp/protocol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d3d50da..a36f2e2 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1597,6 +1597,6 @@ MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
 MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
 MODULE_AUTHOR("Linux Kernel SCTP developers <linux-sctp@vger.kernel.org>");
 MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
-module_param_named(no_checksums, sctp_checksum_disable, bool, 0644);
+module_param_named(no_checksums, sctp_checksum_disable, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(no_checksums, "Disable checksums computing and verification");
 MODULE_LICENSE("GPL");
-- 
2.9.2
