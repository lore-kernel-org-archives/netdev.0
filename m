From: Nik Nyby <nikolas@gnu.org>
Subject: [PATCH] rtlwifi: rtl8821ae: Fix typo in variable name
Date: Mon, 23 Oct 2017 21:49:09 -0400
Message-ID: <20171024014909.7347-1-nikolas@gnu.org>
Cc: Nik Nyby <nikolas@gnu.org>
To: Larry.Finger@lwfinger.net, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eggs.gnu.org ([208.118.235.92]:41190 "EHLO eggs.gnu.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751226AbdJXBto (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Oct 2017 21:49:44 -0400
Received: from Debian-exim by eggs.gnu.org with spam-scanned (Exim 4.71)
        (envelope-from <nikolas@gnu.org>)
        id 1e6oLf-0006Qa-1l
        for netdev@vger.kernel.org; Mon, 23 Oct 2017 21:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In _rtl8821ae_dbi_write(), wrtie_addr should be write_addr.

Signed-off-by: Nik Nyby <nikolas@gnu.org>
---
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
index 1d431d4bf6d2..6a9d8ee0ae9f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
@@ -1130,13 +1130,13 @@ static u8 _rtl8821ae_dbi_read(struct rtl_priv *rtlpriv, u16 addr)
 static void _rtl8821ae_dbi_write(struct rtl_priv *rtlpriv, u16 addr, u8 data)
 {
 	u8 tmp = 0, count = 0;
-	u16 wrtie_addr, remainder = addr % 4;
+	u16 write_addr, remainder = addr % 4;
 
-	wrtie_addr = REG_DBI_WDATA + remainder;
-	rtl_write_byte(rtlpriv, wrtie_addr, data);
+	write_addr = REG_DBI_WDATA + remainder;
+	rtl_write_byte(rtlpriv, write_addr, data);
 
-	wrtie_addr = (addr & 0xfffc) | (BIT(0) << (remainder + 12));
-	rtl_write_word(rtlpriv, REG_DBI_ADDR, wrtie_addr);
+	write_addr = (addr & 0xfffc) | (BIT(0) << (remainder + 12));
+	rtl_write_word(rtlpriv, REG_DBI_ADDR, write_addr);
 
 	rtl_write_byte(rtlpriv, REG_DBI_FLAG, 0x1);
 
-- 
2.14.2
