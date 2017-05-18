From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] r8152: Remove unused function usb_ocp_read()
Date: Thu, 18 May 2017 10:45:33 -0700
Message-ID: <20170518174533.79413-1-mka@chromium.org>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>
To: "David S . Miller" <davem@davemloft.net>,
        hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33631 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755059AbdERRpk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 13:45:40 -0400
Received: by mail-pf0-f178.google.com with SMTP id e193so27293507pfh.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 10:45:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function is not used, removing it fixes the following warning when
building with clang:

drivers/net/usb/r8152.c:825:5: error: unused function 'usb_ocp_read'
    [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 drivers/net/usb/r8152.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ddc62cb69be8..e902df9595b9 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -841,12 +841,6 @@ int pla_ocp_write(struct r8152 *tp, u16 index, u16 byteen, u16 size, void *data)
 }
 
 static inline
-int usb_ocp_read(struct r8152 *tp, u16 index, u16 size, void *data)
-{
-	return generic_ocp_read(tp, index, size, data, MCU_TYPE_USB);
-}
-
-static inline
 int usb_ocp_write(struct r8152 *tp, u16 index, u16 byteen, u16 size, void *data)
 {
 	return generic_ocp_write(tp, index, byteen, size, data, MCU_TYPE_USB);
-- 
2.13.0.303.g4ebf302169-goog
