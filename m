From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH linux-firmware] tg3: Add EEE support firmware for 57766
 cards
Date: Wed, 6 Mar 2013 16:07:25 -0800
Message-ID: <1362614845-20738-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1446 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932189Ab3CGAIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 19:08:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

57766 devices with no nvram need a service patch firmware for the boot
code to support EEE. This patch adds the fw.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 WHENCE             |   3 ++-
 tigon/tg357766.bin | Bin 0 -> 144 bytes
 2 files changed, 2 insertions(+), 1 deletion(-)
 create mode 100644 tigon/tg357766.bin

diff --git a/WHENCE b/WHENCE
index 7c2c921..1d1f5b7 100644
--- a/WHENCE
+++ b/WHENCE
@@ -602,11 +602,12 @@ Driver: tg3 -- Broadcom Tigon3 based gigabit Ethernet cards
 File: tigon/tg3.bin
 File: tigon/tg3_tso.bin
 File: tigon/tg3_tso5.bin
+File: tigon/tg357766.bin
 
 Licence:
  * Firmware is:
  *	Derived from proprietary unpublished source code,
- *	Copyright (C) 2000-2003 Broadcom Corporation.
+ *	Copyright (C) 2000-2013 Broadcom Corporation.
  *
  *	Permission is hereby granted for the distribution of this firmware
  *	data in hexadecimal or equivalent format, provided this copyright
diff --git a/tigon/tg357766.bin b/tigon/tg357766.bin
new file mode 100644
index 0000000000000000000000000000000000000000..b7816a0776262b3323f99f7dd071f3fdc31a2ba9
GIT binary patch
literal 144
zcmZQz00L$PhW|it@6_+LAT|)Bs5dY$e*fTLcUHr!M36y{;roAq6!Sa=M)d>+hVLKh
zUw!|;zyib)X9Uc27$g`Z#2Y~33>=3o%r=1JjsWRn3TAtNW^tYdvVro9;t32~5Ig<?
Vg&71cxZDtf@c*0v@tF*mm;f?XF`fVb

literal 0
HcmV?d00001

-- 
1.8.1.4
