From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net 2/3] net/hsr: Very small fix of comment style.
Date: Fri, 29 Nov 2013 23:37:07 +0100
Message-ID: <52991713.8060701@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	=?UTF-8?B?RWzDrWFzIE1vbGluYSBNdcOxb3o=?= <elias.molina@ehu.es>,
	Arvid Brodin <arvid.brodin@alten.se>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam2.webland.se ([91.207.112.92]:62099 "EHLO spam2.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241Ab3K2Wp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 17:45:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_framereg.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 003f5bb..4bdab15 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -288,7 +288,8 @@ void hsr_addr_subst_dest(struct hsr_priv *hsr_priv,=
 struct ethhdr *ethhdr,
 static bool seq_nr_after(u16 a, u16 b)
 {
 	/* Remove inconsistency where
-	 * seq_nr_after(a, b) =3D=3D seq_nr_before(a, b) */
+	 * seq_nr_after(a, b) =3D=3D seq_nr_before(a, b)
+	 */
 	if ((int) b - a =3D=3D 32768)
 		return false;
=20
--=20
1.8.1.5


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
