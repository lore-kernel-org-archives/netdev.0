From: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Subject: [PATCH v2 6/7] Bluetooth: Add HCI device identifier for Qualcomm SMD
Date: Fri, 9 Oct 2015 13:48:04 -0700
Message-ID: <1444423685-14717-7-git-send-email-bjorn.andersson@sonymobile.com>
References: <1444423685-14717-1-git-send-email-bjorn.andersson@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fengwei Yin <fengwei.yin@linaro.org>,
	Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
	<linux-arm-msm@vger.kernel.org>, <linux-bluetooth@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gross <agross@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444423685-14717-1-git-send-email-bjorn.andersson@sonymobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch assigns the next free HCI device identifier to Bluetooth
devices based on the Qualcomm Shared Memory channels.

Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
---

Changes since v1:
- Split out this from the btqcomsmd patch

 include/net/bluetooth/hci.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index e7f938cac7c6..adfb371a19f9 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -60,6 +60,7 @@
 #define HCI_RS232	4
 #define HCI_PCI		5
 #define HCI_SDIO	6
+#define HCI_SMD		7
 
 /* HCI controller types */
 #define HCI_BREDR	0x00
-- 
2.4.2
