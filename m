From: =?utf-8?q?Rui=20Tiago=20Ca=C3=A7=C3=A3o=20Matos?= <rmatos@av.it.pt>
Subject: [PATCH] Remove usage of C++ keyword 'class' on htb.h header.
Date: Tue,  4 Mar 2008 18:31:16 +0000
Message-ID: <1204655476-2663-2-git-send-email-rmatos@av.it.pt>
References: <1204655476-2663-1-git-send-email-rmatos@av.it.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?q?Rui=20Tiago=20Ca=C3=A7=C3=A3o=20Matos?= <rmatos@av.it.pt>
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:51089 "EHLO av.it.pt"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756600AbYCDTbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 14:31:38 -0500
In-Reply-To: <1204655476-2663-1-git-send-email-rmatos@av.it.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Rui Tiago Ca=C3=A7=C3=A3o Matos <rmatos@av.it.pt>
---
 include/netlink/route/sch/htb.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/netlink/route/sch/htb.h b/include/netlink/route/sc=
h/htb.h
index 5d4d681..d44f039 100644
--- a/include/netlink/route/sch/htb.h
+++ b/include/netlink/route/sch/htb.h
@@ -30,9 +30,9 @@ extern void rtnl_htb_set_rate(struct rtnl_class *, ui=
nt32_t);
 extern void rtnl_htb_set_ceil(struct rtnl_class *, uint32_t);
 extern void rtnl_htb_set_rbuffer(struct rtnl_class *, uint32_t);
 extern void rtnl_htb_set_cbuffer(struct rtnl_class *, uint32_t);
-extern void rtnl_htb_set_quantum(struct rtnl_class *class, uint32_t qu=
antum);
-extern void rtnl_htb_set_overhead(struct rtnl_class *class, uint8_t ov=
erhead);
-extern void rtnl_htb_set_mpu(struct rtnl_class *class, uint8_t mpu);
+extern void rtnl_htb_set_quantum(struct rtnl_class *, uint32_t quantum=
);
+extern void rtnl_htb_set_overhead(struct rtnl_class *, uint8_t overhea=
d);
+extern void rtnl_htb_set_mpu(struct rtnl_class *, uint8_t mpu);
=20
 #ifdef __cplusplus
 }
--=20
1.5.4.1

