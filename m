From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH] pch_gbe: compilation warning in pch_gbe_setup_rctl() fixed
Date: Fri, 7 Oct 2011 11:59:19 +0400
Message-ID: <1317974359-20548-1-git-send-email-vvs@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>,
	Vasily Averin <vvs@sw.ru>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:60535 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab1JGH72 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 03:59:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Vasily Averin <vvs@sw.ru>

compilation warning fixed
drivers/net/pch_gbe/pch_gbe_main.c: In function =E2=80=98pch_gbe_setup_=
rctl=E2=80=99:
drivers/net/pch_gbe/pch_gbe_main.c:701:21: warning: unused variable =E2=
=80=98netdev=E2=80=99

Signed-off-by: Vasily Averin <vvs@sw.ru>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/p=
ch_gbe_main.c
index b8b4ba2..7659324 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -698,7 +698,6 @@ static void pch_gbe_configure_tx(struct pch_gbe_ada=
pter *adapter)
  */
 static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
 {
-	struct net_device *netdev =3D adapter->netdev;
 	struct pch_gbe_hw *hw =3D &adapter->hw;
 	u32 rx_mode, tcpip;
=20
--=20
1.7.4.1
