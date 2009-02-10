From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: fix double free in GPRS outbound packet error path
Date: Tue, 10 Feb 2009 16:23:54 +0200
Message-ID: <1234275835-14402-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:31925 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbZBJOYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 09:24:19 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n1AENu4F001908
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:24:16 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n1AENs7g019130
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:23:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Remi Denis-Courmont" <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 6a91a32..4aa8885 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -207,7 +207,6 @@ static int gprs_xmit(struct sk_buff *skb, struct ne=
t_device *dev)
 				dev->name, err);
 		dev->stats.tx_aborted_errors++;
 		dev->stats.tx_errors++;
-		dev_kfree_skb(skb);
 	} else {
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes +=3D len;
--=20
1.5.6.5

