From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 6/8] [NETFILTER] xt_policy.c: kill some bloat
Date: Sat, 12 Jan 2008 11:40:15 +0200
Message-ID: <12001308172525-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817405-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38124 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761145AbYALJkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:21 -0500
In-Reply-To: <1200130817405-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/netfilter/xt_policy.c:
  policy_mt | -906
 1 function changed, 906 bytes removed, diff: -906

net/netfilter/xt_policy.c:
  match_xfrm_state | +427
 1 function changed, 427 bytes added, diff: +427

net/netfilter/xt_policy.o:
 2 functions changed, 427 bytes added, 906 bytes removed, diff: -479

Alternatively, this could be done by combining identical
parts of the match_policy_in/out()

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/netfilter/xt_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 46ee7e8..45731ca 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -33,7 +33,7 @@ xt_addr_cmp(const union xt_policy_addr *a1, const uni=
on xt_policy_addr *m,
 	return false;
 }
=20
-static inline bool
+static bool
 match_xfrm_state(const struct xfrm_state *x, const struct xt_policy_el=
em *e,
 		 unsigned short family)
 {
--=20
1.5.0.6

