From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 05/11] Removing dead CASSINI_NAPI
Date: Wed, 14 Jul 2010 14:40:59 +0200
Message-ID: <582064a9d6be5cc6f620884ed5120ceb21fdbb12.1279110895.git.siccegge__48170.708519365$1279111370$gmane$org@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43623 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756565Ab0GNMlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:41:00 -0400
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CASSINI_NAPI doesn't exist in Kconfig, therefore removing all
references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/cassini.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 0d911ba..28c88ee 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -107,12 +107,7 @@
 #define cas_page_unmap(x)    kunmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
 #define CAS_NCPUS            num_online_cpus()
 
-#ifdef CONFIG_CASSINI_NAPI
-#define USE_NAPI
-#define cas_skb_release(x)  netif_receive_skb(x)
-#else
 #define cas_skb_release(x)  netif_rx(x)
-#endif
 
 /* select which firmware to use */
 #define USE_HP_WORKAROUND
-- 
1.7.0.4

