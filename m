From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] dccp: use roundup instead of opencoding
Date: Fri, 5 Dec 2008 23:43:28 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812052342180.3726@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-191728806-1228513408=:3726"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54837 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbYLEVna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 16:43:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-191728806-1228513408=:3726
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/dccp/output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/output.c b/net/dccp/output.c
index fea30cd..1b75ece 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -175,7 +175,7 @@ unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu)
 	 * make it a multiple of 4
 	 */
 
-	cur_mps -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
+	cur_mps -= roundup(5 + 6 + 10 + 6 + 6 + 6);
 
 	/* And store cached results */
 	icsk->icsk_pmtu_cookie = pmtu;
-- 
1.5.2.2
---696208474-191728806-1228513408=:3726--
