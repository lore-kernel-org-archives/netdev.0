From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next] Revert "ipv4: Clarify in docs that accept_local requires rp_filter."
Date: Wed, 10 Sep 2014 18:20:23 +0200
Message-ID: <1410366023-9129-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>, Julian Anastasov <ja@ssi.bg>,
	<netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:53214 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbaIJQ0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 12:26:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit c801e3cc1925 ("ipv4: Clarify in docs that accept_lo=
cal requires rp_filter.").
It is not needed anymore since commit 1dced6a85482 ("ipv4: Restore acce=
pt_local behaviour in fib_validate_source()").

Suggested-by: Julian Anastasov <ja@ssi.bg>
Cc: Gregory Detal <gregory.detal@uclouvain.be>
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
Cc: Hannes Frederic Sowa <hannes@redhat.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---
 Documentation/networking/ip-sysctl.txt | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index db2383c..1b5581a 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -952,14 +952,9 @@ accept_source_route - BOOLEAN
 		FALSE (host)
=20
 accept_local - BOOLEAN
-	Accept packets with local source addresses. In combination
-	with suitable routing, this can be used to direct packets
-	between two local interfaces over the wire and have them
-	accepted properly.
-
-	rp_filter must be set to a non-zero value in order for
-	accept_local to have an effect.
-
+	Accept packets with local source addresses. In combination with
+	suitable routing, this can be used to direct packets between two
+	local interfaces over the wire and have them accepted properly.
 	default FALSE
=20
 route_localnet - BOOLEAN
--=20
tg: (6618ec6..) net-next/accept_local-update-doc (depends on: net-next/=
master)
