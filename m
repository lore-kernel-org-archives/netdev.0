From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 5/9] I/OAT: Add documentation for the tcp_dma_copybreak sysctl
Date: Fri, 02 Mar 2007 18:24:26 -0800
Message-ID: <20070303022426.31033.35991.stgit@gitlost.site>
References: <20070303022238.31033.84558.stgit@gitlost.site>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1461 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992908AbXCCCjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 21:39:11 -0500
In-Reply-To: <20070303022238.31033.84558.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 Documentation/networking/ip-sysctl.txt |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d3aae1f..9541691 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -413,6 +413,12 @@ tcp_workaround_signed_windows - BOOLEAN
 	not receive a window scaling option from them.
 	Default: 0
 
+tcp_dma_copybreak - INTEGER
+	Lower limit, in bytes, of the size of socket reads that will be
+	offloaded to a DMA copy engine, if one is present in the system
+	and CONFIG_NET_DMA is enabled.
+	Default: 4096
+
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN

