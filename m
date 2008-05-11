From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH] net/s2io: set_rxd_buffer_pointer returns -ENOMEM, not
	ENOMEM
Date: Sun, 11 May 2008 22:04:25 +0200
Message-ID: <20080511200421.GK19058@joi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:51990 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796AbYEKUFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2008 16:05:02 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1541916fgg.17
        for <netdev@vger.kernel.org>; Sun, 11 May 2008 13:04:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Cc: netdev@vger.kernel.org
---
compile tested only
---
 drivers/net/s2io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6951,7 +6951,7 @@ static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 						       &skb,(u64 *)&temp0_64,
 						       (u64 *)&temp1_64,
 						       (u64 *)&temp2_64,
-							size) == ENOMEM) {
+							size) == -ENOMEM) {
 					return 0;
 				}
 
-- 
