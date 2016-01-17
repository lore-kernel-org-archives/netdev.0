From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] tcp_memcontrol: Forward declare cgroup_subsys and mem_cgroup stucts
Date: Sun, 17 Jan 2016 11:30:37 +0100
Message-ID: <1453026637-9942-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:58526 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbcAQOJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 09:09:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In file included from net/ipv4/tcp_ipv4.c:77 (and many more):
include/net/tcp_memcontrol.h:5: warning: =E2=80=98struct cgroup_subsys=E2=
=80=99 declared inside parameter list
include/net/tcp_memcontrol.h:5: warning: its scope is only this definit=
ion or declaration, which is probably not what you want

Add forward declarations for all used structures to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 include/net/tcp_memcontrol.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.=
h
index 3a17b16ae8aa47c4..01ff7c6efada9797 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -1,6 +1,9 @@
 #ifndef _TCP_MEMCG_H
 #define _TCP_MEMCG_H
=20
+struct cgroup_subsys;
+struct mem_cgroup;
+
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss=
);
 void tcp_destroy_cgroup(struct mem_cgroup *memcg);
 #endif /* _TCP_MEMCG_H */
--=20
1.9.1
