From: Connor Behan <connor.behan@gmail.com>
Subject: [PATCH] Remove executable permissions from firmware files
Date: Sat, 25 Jan 2014 16:51:04 -0800
Message-ID: <1390697464-7137-1-git-send-email-connor.behan@gmail.com>
Content-Type: text/plain; charset="utf-8"
Cc: netdev@vger.kernel.org, Connor Behan <connor.behan@gmail.com>
To: dwmw2@infradead.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:57872 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbaAZA63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 19:58:29 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so4586798pab.5
        for <netdev@vger.kernel.org>; Sat, 25 Jan 2014 16:58:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should change these permissions unless there is a reason to keep them
executable.

Signed-off-by: Connor Behan <connor.behan@gmail.com>
---
 ar3k/AthrBT_0x41020000.dfu     | Bin
 ar3k/ramps_0x41020000_40.dfu   | Bin
 ar5523.bin                     | Bin
 carl9170fw/carlfw/src/printf.c |   0
 rtlwifi/rtl8723fw.bin          | Bin
 rtlwifi/rtl8723fw_B.bin        | Bin
 6 files changed, 0 insertions(+), 0 deletions(-)
 mode change 100755 => 100644 ar3k/AthrBT_0x41020000.dfu
 mode change 100755 => 100644 ar3k/ramps_0x41020000_40.dfu
 mode change 100755 => 100644 ar5523.bin
 mode change 100755 => 100644 carl9170fw/carlfw/src/printf.c
 mode change 100755 => 100644 rtlwifi/rtl8723fw.bin
 mode change 100755 => 100644 rtlwifi/rtl8723fw_B.bin

diff --git a/ar3k/AthrBT_0x41020000.dfu b/ar3k/AthrBT_0x41020000.dfu
old mode 100755
new mode 100644
diff --git a/ar3k/ramps_0x41020000_40.dfu b/ar3k/ramps_0x41020000_40.dfu
old mode 100755
new mode 100644
diff --git a/ar5523.bin b/ar5523.bin
old mode 100755
new mode 100644
diff --git a/carl9170fw/carlfw/src/printf.c b/carl9170fw/carlfw/src/printf.c
old mode 100755
new mode 100644
diff --git a/rtlwifi/rtl8723fw.bin b/rtlwifi/rtl8723fw.bin
old mode 100755
new mode 100644
diff --git a/rtlwifi/rtl8723fw_B.bin b/rtlwifi/rtl8723fw_B.bin
old mode 100755
new mode 100644
-- 
1.8.5.2
