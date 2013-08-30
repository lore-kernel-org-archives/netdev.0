From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 5/9] net: team: inherit addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 18:08:48 +0200
Message-ID: <1377878932-26881-6-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55485 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754209Ab3H3QKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:10:14 -0400
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device inheriting a random or set address should reflect this in
its addr_assign_type.

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/team/team.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9ccccd4..50e43e6 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1974,7 +1974,7 @@ static void team_setup_by_port(struct net_device =
*dev,
 	dev->addr_len =3D port_dev->addr_len;
 	dev->mtu =3D port_dev->mtu;
 	memcpy(dev->broadcast, port_dev->broadcast, port_dev->addr_len);
-	memcpy(dev->dev_addr, port_dev->dev_addr, port_dev->addr_len);
+	eth_hw_addr_inherit(dev, port_dev);
 }
=20
 static int team_dev_type_check_change(struct net_device *dev,
--=20
1.7.10.4
