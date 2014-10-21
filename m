From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next] Removed unused function sctp_addr_is_valid()
Date: Tue, 21 Oct 2014 15:26:15 +0200
Message-ID: <1413897975-6066-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:43157 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932400AbaJUN1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 09:27:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_addr_is_valid() only appeared in its definition.

Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---

Note: originally sent on linux-sctp (11/10/2014, 16:29).
Sorry, I should probably have sent immediately to you and netdev as wel=
l.
Neil Horman had acked the patch, so I included
the ack here.

 include/net/sctp/structs.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4ff3f67..806e3b5 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1116,7 +1116,6 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr =
*bp, __u8 *raw, int len,
 sctp_scope_t sctp_scope(const union sctp_addr *);
 int sctp_in_scope(struct net *net, const union sctp_addr *addr, const =
sctp_scope_t scope);
 int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
-int sctp_addr_is_valid(const union sctp_addr *addr);
 int sctp_is_ep_boundall(struct sock *sk);
=20
=20
--=20
tg: (61ed53d..) net-next/removed-unused-sctp-function (depends on: net-=
next/master)
