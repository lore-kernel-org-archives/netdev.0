From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH] staging: et131x: Fix all sparse warnings
Date: Sat, 19 Jan 2013 11:48:29 +0000
Message-ID: <1358596109-30106-1-git-send-email-mark.einon@gmail.com>
References: <20130119110328.GO4584@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org, dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:59108 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909Ab3ASLso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 06:48:44 -0500
In-Reply-To: <20130119110328.GO4584@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter has pointed out that there are several sparse warnings
from et131x.c, listed below. This patch fixes all these errors.

drivers/staging/et131x/et131x.c:1870:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1870:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *num_des
drivers/staging/et131x/et131x.c:1870:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1871:37: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1871:37: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *full_offset
drivers/staging/et131x/et131x.c:1871:37: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1872:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1872:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *min_des
drivers/staging/et131x/et131x.c:1872:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1873:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1873:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *base_hi
drivers/staging/et131x/et131x.c:1873:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1874:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1874:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *base_lo
drivers/staging/et131x/et131x.c:1874:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1876:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1876:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *num_des
drivers/staging/et131x/et131x.c:1876:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1877:37: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1877:37: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *full_offset
drivers/staging/et131x/et131x.c:1877:37: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1878:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1878:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *min_des
drivers/staging/et131x/et131x.c:1878:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1879:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1879:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *base_hi
drivers/staging/et131x/et131x.c:1879:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1880:33: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:1880:33: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *base_lo
drivers/staging/et131x/et131x.c:1880:33: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:1898:24: warning: incorrect type in arg=
ument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1898:24: =C2=A0 =C2=A0expected void vol=
atile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1898:24: =C2=A0 =C2=A0got unsigned int =
[usertype] *base_hi
drivers/staging/et131x/et131x.c:1900:24: warning: incorrect type in arg=
ument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1900:24: =C2=A0 =C2=A0expected void vol=
atile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1900:24: =C2=A0 =C2=A0got unsigned int =
[usertype] *base_lo
drivers/staging/et131x/et131x.c:1901:60: warning: incorrect type in arg=
ument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1901:60: =C2=A0 =C2=A0expected void vol=
atile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1901:60: =C2=A0 =C2=A0got unsigned int =
[usertype] *num_des
drivers/staging/et131x/et131x.c:1902:39: warning: incorrect type in arg=
ument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1902:39: =C2=A0 =C2=A0expected void vol=
atile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1902:39: =C2=A0 =C2=A0got unsigned int =
[usertype] *full_offset
drivers/staging/et131x/et131x.c:1910:24: warning: incorrect type in arg=
ument 2 (different address spaces)
drivers/staging/et131x/et131x.c:1910:24: =C2=A0 =C2=A0expected void vol=
atile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:1910:24: =C2=A0 =C2=A0got unsigned int =
[usertype] *min_des
drivers/staging/et131x/et131x.c:2583:32: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:2583:32: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *offset
drivers/staging/et131x/et131x.c:2583:32: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:2585:32: warning: incorrect type in ass=
ignment (different address spaces)
drivers/staging/et131x/et131x.c:2585:32: =C2=A0 =C2=A0expected unsigned=
 int [usertype] *offset
drivers/staging/et131x/et131x.c:2585:32: =C2=A0 =C2=A0got unsigned int =
[noderef] <asn:2>*<noident>
drivers/staging/et131x/et131x.c:2602:24: warning: incorrect type in arg=
ument 2 (different address spaces)
drivers/staging/et131x/et131x.c:2602:24: =C2=A0 =C2=A0expected void vol=
atile [noderef] <asn:2>*addr
drivers/staging/et131x/et131x.c:2602:24: =C2=A0 =C2=A0got unsigned int =
[usertype] *offset
drivers/staging/et131x/et131x.c:4093:13: warning: symbol 'et131x_isr' w=
as not declared. Should it be static?

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/e=
t131x.c
index 82508fb..f0bc7ba 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -1860,11 +1860,11 @@ static void et131x_config_rx_dma_regs(struct et=
131x_adapter *adapter)
 	rx_local->local_psr_full =3D 0;
=20
 	for (id =3D 0; id < NUM_FBRS; id++) {
-		u32 *num_des;
-		u32 *full_offset;
-		u32 *min_des;
-		u32 *base_hi;
-		u32 *base_lo;
+		u32 __iomem *num_des;
+		u32 __iomem *full_offset;
+		u32 __iomem *min_des;
+		u32 __iomem *base_hi;
+		u32 __iomem *base_lo;
=20
 		if (id =3D=3D 0) {
 			num_des =3D &rx_dma->fbr0_num_des;
@@ -2574,7 +2574,7 @@ static void nic_return_rfd(struct et131x_adapter =
*adapter, struct rfd *rfd)
 	 * need to clean up OOB data
 	 */
 	if (buff_index < rx_local->fbr[ring_index]->num_entries) {
-		u32 *offset;
+		u32 __iomem *offset;
 		struct fbr_desc *next;
=20
 		spin_lock_irqsave(&adapter->fbr_lock, flags);
@@ -4090,7 +4090,7 @@ static SIMPLE_DEV_PM_OPS(et131x_pm_ops, et131x_su=
spend, et131x_resume);
  *
  * Returns a value indicating if the interrupt was handled.
  */
-irqreturn_t et131x_isr(int irq, void *dev_id)
+static irqreturn_t et131x_isr(int irq, void *dev_id)
 {
 	bool handled =3D true;
 	struct net_device *netdev =3D (struct net_device *)dev_id;
--=20
1.7.9.5
