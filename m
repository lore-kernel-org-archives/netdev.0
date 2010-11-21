From: Joe Perches <joe@perches.com>
Subject: [PATCH 60/62] rt2x00: Use static const
Date: Sat, 20 Nov 2010 18:39:01 -0800
Message-ID: <d8bfaded20da2265673391a81536d63b0e81dc7f.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1759 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756972Ab0KUCkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:47 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  40197	     56	   8336	  48589	   bdcd	drivers/net/wireless/rt2x00/rt2800lib.o.new
  40205	     56	   8336	  48597	   bdd5	drivers/net/wireless/rt2x00/rt2800lib.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rt2x00/rt2800lib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index ce8df66..7563161 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2166,7 +2166,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 					 SHARED_KEY_MODE_ENTRY(i), 0);
 
 	for (i = 0; i < 256; i++) {
-		u32 wcid[2] = { 0xffffffff, 0x00ffffff };
+		static const u32 wcid[2] = { 0xffffffff, 0x00ffffff };
 		rt2800_register_multiwrite(rt2x00dev, MAC_WCID_ENTRY(i),
 					      wcid, sizeof(wcid));
 
-- 
1.7.3.2.245.g03276.dirty

