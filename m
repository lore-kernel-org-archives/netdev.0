From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/8] [XFRM] xfrm_policy: kill some bloat
Date: Sat, 12 Jan 2008 11:40:12 +0200
Message-ID: <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35414 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761248AbYALJkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:20 -0500
In-Reply-To: <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/xfrm/xfrm_policy.c:
  xfrm_audit_policy_delete | -692
  xfrm_audit_policy_add    | -692
 2 functions changed, 1384 bytes removed, diff: -1384

net/xfrm/xfrm_policy.c:
  xfrm_audit_common_policyinfo | +704
 1 function changed, 704 bytes added, diff: +704

net/xfrm/xfrm_policy.o:
 3 functions changed, 704 bytes added, 1384 bytes removed, diff: -680

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 534b29e..47219f9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2367,8 +2367,8 @@ void __init xfrm_init(void)
 }
=20
 #ifdef CONFIG_AUDITSYSCALL
-static inline void xfrm_audit_common_policyinfo(struct xfrm_policy *xp=
,
-						struct audit_buffer *audit_buf)
+static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
+					 struct audit_buffer *audit_buf)
 {
 	struct xfrm_sec_ctx *ctx =3D xp->security;
 	struct xfrm_selector *sel =3D &xp->selector;
--=20
1.5.0.6

