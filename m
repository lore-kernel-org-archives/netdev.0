From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 1/2] blackfin: tcm-bf518: Remove dsa.h inclusion
Date: Tue, 19 Sep 2017 18:03:45 -0700
Message-ID: <20170920010346.16871-2-f.fainelli@gmail.com>
References: <20170920010346.16871-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, realmz6@gmail.com,
        adi-buildroot-devel@lists.sourceforge.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36956 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751533AbdITBDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:03:54 -0400
Received: by mail-qt0-f193.google.com with SMTP id u48so839466qtc.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 18:03:54 -0700 (PDT)
In-Reply-To: <20170920010346.16871-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nothing in that file uses definitions from that header, so just get rid of it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/blackfin/mach-bf518/boards/tcm-bf518.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/blackfin/mach-bf518/boards/tcm-bf518.c b/arch/blackfin/mach-bf518/boards/tcm-bf518.c
index 240d5cb1f02c..37d868085f6a 100644
--- a/arch/blackfin/mach-bf518/boards/tcm-bf518.c
+++ b/arch/blackfin/mach-bf518/boards/tcm-bf518.c
@@ -25,7 +25,6 @@
 #include <asm/dpmc.h>
 #include <asm/bfin_sdh.h>
 #include <linux/spi/ad7877.h>
-#include <net/dsa.h>
 
 /*
  * Name the Board for the /proc/cpuinfo
-- 
2.11.0
