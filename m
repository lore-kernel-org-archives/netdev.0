From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 5/7] I/OAT: Add documentation for the tcp_dma_copybreak sysctl
Date: Wed, 18 Oct 2006 16:46:57 -0700
Message-ID: <20061018234657.26671.7365.stgit@gitlost.site>
References: <20061018234417.26671.56773.stgit@gitlost.site>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:53006 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1423163AbWJRXjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 19:39:03 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jeff@garzik.org
In-Reply-To: <20061018234417.26671.56773.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 Documentation/networking/ip-sysctl.txt |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index fd3c0c0..e9ee102 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -375,6 +375,12 @@ tcp_slow_start_after_idle - BOOLEAN
 	be timed out after an idle period.
 	Default: 1
 
+tcp_dma_copybreak - INTEGER
+	Lower limit, in bytes, of the size of socket reads that will be
+	offloaded to a DMA copy engine, if one is present in the system
+	and CONFIG_NET_DMA is enabled.
+	Default: 4096
+
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN

