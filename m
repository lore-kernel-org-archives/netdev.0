From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: do not compute unused value
Date: Tue, 10 Feb 2009 16:23:55 +0200
Message-ID: <1234275835-14402-2-git-send-email-remi.denis-courmont@nokia.com>
References: <1234275835-14402-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:31927 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbZBJOYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 09:24:20 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n1AENu4H001908
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:24:17 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n1AENs7h019130
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:23:58 +0200
In-Reply-To: <1234275835-14402-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Remi Denis-Courmont" <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index bb3e678..8ad2b53 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -553,7 +553,7 @@ static int pep_do_rcv(struct sock *sk, struct sk_bu=
ff *skb)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct sock *sknode;
-	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	struct pnpipehdr *hdr;
 	struct sockaddr_pn dst;
 	int err =3D NET_RX_SUCCESS;
 	u8 pipe_handle;
--=20
1.5.6.5

