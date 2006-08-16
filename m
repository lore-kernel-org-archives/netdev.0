From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 6/7] [I/OAT] Add documentation for the tcp_dma_copybreak sysctl
Date: Tue, 15 Aug 2006 17:53:48 -0700
Message-ID: <20060816005348.8634.2415.stgit@gitlost.site>
References: <20060816005337.8634.70033.stgit@gitlost.site>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750788AbWHPAql@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20060816005337.8634.70033.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 Documentation/networking/ip-sysctl.txt |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d46338a..841d61e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -369,6 +369,12 @@ tcp_slow_start_after_idle - BOOLEAN
 	be timed out after an idle period.
 	Default: 1
 
+tcp_dma_copybreak - INTEGER
+	Lower limit, in bytes, of the size of socket reads that will be
+	offloaded to a DMA copy engine, if one is present in the system
+	and CONFIG_NET_DMA is enabled.
+	Default: 4096
+
 IP Variables:
 
 ip_local_port_range - 2 INTEGERS
