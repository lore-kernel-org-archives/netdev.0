From: Yannick Guerrini <yguerrini@tomshardware.fr>
Subject: [PATCHv2] r8169: Fix trivial typo in rtl_check_firmware
Date: Tue, 24 Feb 2015 13:03:51 +0100
Message-ID: <1424779431-5760-1-git-send-email-yguerrini@tomshardware.fr>
References: <1424764149-9136-1-git-send-email-yguerrini@tomshardware.fr>
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hayeswang@realtek.com,
	Yannick Guerrini <yguerrini@tomshardware.fr>
To: nic_swsd@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424764149-9136-1-git-send-email-yguerrini@tomshardware.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change 'firwmare' to 'firmware'

Signed-off-by: Yannick Guerrini <yguerrini@tomshardware.fr>
---
v2: replace "drivers, realtek" of the subject with "r8169" and cc netdev@vger.kernel.org,
    as suggested by Hayes Wang <hayeswang@realtek.com>

 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b156092..c70ab40 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2561,7 +2561,7 @@ static int rtl_check_firmware(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 	int rc = -EINVAL;
 
 	if (!rtl_fw_format_ok(tp, rtl_fw)) {
-		netif_err(tp, ifup, dev, "invalid firwmare\n");
+		netif_err(tp, ifup, dev, "invalid firmware\n");
 		goto out;
 	}
 
-- 
1.9.5.msysgit.0
