From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: dsa: remove ethtool_ops->set_sg
Date: Tue, 19 Apr 2011 12:43:19 +0200 (CEST)
Message-ID: <20110419104320.032B713909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46856 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab1DSKnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 06:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove set_sg from DSA slave ethtool_ops. Features inheritance looks
broken/not fully implemented anyway.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/dsa/slave.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64ca2a6..0a47b6c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -288,7 +288,6 @@ static const struct ethtool_ops dsa_slave_ethtool_o=
ps =3D {
 	.get_drvinfo		=3D dsa_slave_get_drvinfo,
 	.nway_reset		=3D dsa_slave_nway_reset,
 	.get_link		=3D dsa_slave_get_link,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D dsa_slave_get_strings,
 	.get_ethtool_stats	=3D dsa_slave_get_ethtool_stats,
 	.get_sset_count		=3D dsa_slave_get_sset_count,
--=20
1.7.2.5

