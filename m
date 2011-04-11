From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH 4/4] bonding:fix two typos
Date: Mon, 11 Apr 2011 18:16:32 +0800
Message-ID: <1302516993-9612-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

replace relpy with reply.
replace premanent with permanent.

Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@gm=
ail.com>
---
 drivers/net/bonding/bond_alb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
index 9bc5de3..6e176d6 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -701,7 +701,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *s=
kb, struct bonding *bond)
 		 */
 		rlb_choose_channel(skb, bond);
=20
-		/* The ARP relpy packets must be delayed so that
+		/* The ARP reply packets must be delayed so that
 		 * they can cancel out the influence of the ARP request.
 		 */
 		bond->alb_info.rlb_update_delay_counter =3D RLB_UPDATE_DELAY;
@@ -1042,7 +1042,7 @@ static void alb_change_hw_addr_on_detach(struct b=
onding *bond, struct slave *sla
  *
  * If the permanent hw address of @slave is @bond's hw address, we nee=
d to
  * find a different hw address to give @slave, that isn't in use by an=
y other
- * slave in the bond. This address must be, of course, one of the prem=
anent
+ * slave in the bond. This address must be, of course, one of the perm=
anent
  * addresses of the other slaves.
  *
  * We go over the slave list, and for each slave there we compare its
--=20
1.7.4
