From: <jie.yang@atheros.com>
Subject: [PATCH net-next] atl1e:remove unnecessary crc inversion
Date: Fri, 14 Nov 2008 16:58:07 +0800
Message-ID: <12266530874043-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pyunyh@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:51352 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbYKNI6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 03:58:10 -0500
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 00:58:10 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

remove unnecessary crc inversion.

Signed-off-by: Jie Yang <jie.yang @atheros.com>
---

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 8cbc1b5..a2c93d1 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -174,7 +174,6 @@ u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
        int i;

        crc32 = ether_crc_le(6, mc_addr);
-       crc32 = ~crc32;
        for (i = 0; i < 32; i++)
                value |= (((crc32 >> i) & 1) << (31 - i));


