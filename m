From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 01/26] IPVS: Add CONFIG_IP_VS_IPV6 option for IPv6 support.
Date: Wed, 11 Jun 2008 19:11:44 +0200
Message-ID: <1213204329-10973-2-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add boolean config option CONFIG_IP_VS_IPV6 for enabling experimental IPv6
support in IPVS. Only visible if IPv6 support is set to 'y' or both IPv6
and IPVS are modules.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 09d0c3f..fd24182 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -24,6 +24,14 @@ menuconfig IP_VS
 
 if IP_VS
 
+config	IP_VS_IPV6
+	bool "IPv6 support for IPVS (DANGEROUS)"
+	depends on EXPERIMENTAL && (IPV6 = y || IP_VS = IPV6)
+	---help---
+	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
+
+	  Say N if unsure.
+
 config	IP_VS_DEBUG
 	bool "IP virtual server debugging"
 	---help---
-- 
1.5.3.6

