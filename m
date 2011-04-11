From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH 1/2] bonding:delete unused alb_timer
Date: Mon, 11 Apr 2011 16:17:24 +0800
Message-ID: <7e091c9bb158d01e48302254db8feaf54c731ebf.1302509480.git.panweiping3@gmail.com>
References: <cover.1302509480.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57582 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939Ab1DKIQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 04:16:13 -0400
In-Reply-To: <cover.1302509480.git.panweiping3@gmail.com>
In-Reply-To: <cover.1302509480.git.panweiping3@gmail.com>
References: <cover.1302509480.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now bonding-alb uses delayed_work instead of timer_list.

Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@gm=
ail.com>
---
 drivers/net/bonding/bond_alb.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_=
alb.h
index 86861f0..f2a1d0a 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -122,7 +122,6 @@ struct tlb_slave_info {
 };
=20
 struct alb_bond_info {
-	struct timer_list	alb_timer;
 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
 	spinlock_t		tx_hashtbl_lock;
 	u32			unbalanced_load;
--=20
1.7.4

