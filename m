From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH v3 2/6] GMAC: define clock ID used for GMAC
Date: Mon, 29 Dec 2014 17:43:55 +0800
Message-ID: <1419846235-14603-1-git-send-email-roger.chen@rock-chips.com>
References: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com,
	roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

changes since v2:
1. remove SCLK_MAC_PLL

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 include/dt-bindings/clock/rk3288-cru.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/dt-bindings/clock/rk3288-cru.h b/include/dt-bindings/clock/rk3288-cru.h
index 100a08c..81eb35b 100644
--- a/include/dt-bindings/clock/rk3288-cru.h
+++ b/include/dt-bindings/clock/rk3288-cru.h
@@ -72,6 +72,9 @@
 #define SCLK_HEVC_CABAC		111
 #define SCLK_HEVC_CORE		112
 
+#define SCLK_MAC		151
+#define SCLK_MACREF_OUT		152
+
 #define DCLK_VOP0		190
 #define DCLK_VOP1		191
 
-- 
1.7.9.5
