From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH v2] net: wireless: rtlwifi: rtl8188ee: reg.h:  Cleaning up if statement that always evaluates to false
Date: Sat, 14 Jun 2014 15:27:38 +0200
Message-ID: <1402752458-13836-2-git-send-email-rickard_strandqvist@spectrumdigital.se>
References: <1402752458-13836-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402752458-13836-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found a logical error in an if statement that always evaluates to false.

This has after same discussion resulted in that we add a macro to handle this.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h b/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
index 7af85cf..cd7e7a5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
@@ -411,6 +411,7 @@
 #define	MSR_ADHOC				0x01
 #define	MSR_INFRA				0x02
 #define	MSR_AP					0x03
+#define	MSR_MASK				0x03
 
 #define	RRSR_RSC_OFFSET				21
 #define	RRSR_SHORT_OFFSET			23
-- 
1.7.10.4
