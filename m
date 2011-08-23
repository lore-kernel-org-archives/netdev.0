From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 1/2] bnx2x: resurrect RX hashing
Date: Tue, 23 Aug 2011 18:15:32 +0200
Message-ID: <20110823161530.24707.67923.stgit@dhcp-29-224.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Schmidt <mschmidt@redhat.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	=?utf-8?q?Micha=C5=82?= =?utf-8?b?TWlyb3PFgmF3?=
	<mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1HWQPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 12:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x used to be able to set rxhash, but this was lost in the conversio=
n
to hw_features (commit 66371c441).
Restore it and enable it by default.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
CC: Vladislav Zolotarov <vladz@broadcom.com>
CC: Eilon Greenstein <eilong@broadcom.com>
CC: Dmitry Kravkov <dmitry@broadcom.com>
CC: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers=
/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7204789..85dd294 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10285,8 +10285,8 @@ static int __devinit bnx2x_init_dev(struct pci_=
dev *pdev,
 	dev->priv_flags |=3D IFF_UNICAST_FLT;
=20
 	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM=
 |
-		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
-		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
+		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_LRO |
+		NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
=20
 	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CS=
UM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;

