From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH ethtool] ethtool: Add string/define to display Port Type for Backplane Ethernet
Date: Fri, 2 Aug 2013 10:36:52 +0530
Message-ID: <4f5874f0-845c-429e-8c14-fc948ed7a2e8@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Somnath Kotur <somnath.kotur@emulex.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:2050 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab3HBFID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 01:08:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 ethtool-copy.h |    1 +
 ethtool.c      |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index b5515c2..33ff7d3 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -989,6 +989,7 @@ enum ethtool_sfeatures_retval_bits {
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
 #define PORT_DA			0x05
+#define PORT_BACKPLANE		0x06
 #define PORT_NONE		0xef
 #define PORT_OTHER		0xff
 
diff --git a/ethtool.c b/ethtool.c
index b24b572..4db42b3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -625,6 +625,9 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case PORT_DA:
 		fprintf(stdout, "Direct Attach Copper\n");
 		break;
+	case PORT_BACKPLANE:
+		fprintf(stdout, "BackPlane\n");
+		break;
 	case PORT_NONE:
 		fprintf(stdout, "None\n");
 		break;
-- 
1.7.1
