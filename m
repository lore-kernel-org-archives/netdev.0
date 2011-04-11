From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH 2/2] bonding:delete unused rlb_interval_counter
Date: Mon, 11 Apr 2011 16:17:25 +0800
Message-ID: <dbf419f2037707b09d648931f4ed5913ccfe35d9.1302509480.git.panweiping3@gmail.com>
References: <cover.1302509480.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1302509480.git.panweiping3@gmail.com>
In-Reply-To: <cover.1302509480.git.panweiping3@gmail.com>
References: <cover.1302509480.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now, alb_bond_info uses rx_ntt,rlb_update_delay_counter and
rlb_update_retry_counter to decide when to call rlb_update_rx_clients()=
=2E

Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@gm=
ail.com>
---
 drivers/net/bonding/bond_alb.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_=
alb.h
index f2a1d0a..01ed1fb 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -139,7 +139,6 @@ struct alb_bond_info {
 	struct slave		*next_rx_slave;/* next slave to be assigned
 						* to a new rx client for
 						*/
-	u32			rlb_interval_counter;
 	u8			primary_is_promisc;	   /* boolean */
 	u32			rlb_promisc_timeout_counter;/* counts primary
 							     * promiscuity time
--=20
1.7.4
