From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] net/r8169: add a new chip for RTL8105
Date: Mon, 21 Mar 2011 19:50:30 +0800
Message-ID: <1300708230-1934-3-git-send-email-hayeswang@realtek.com>
References: <1300708230-1934-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300708230-1934-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new chip for RTL8105 whose settings are the same with RTL_GIGA_MAC_VER_30.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 493b0de..0111a14 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1574,6 +1574,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40900000,	RTL_GIGA_MAC_VER_29 },
 		{ 0x7c800000, 0x40800000,	RTL_GIGA_MAC_VER_30 },
-- 
1.7.3.2
