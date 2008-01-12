From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/8] [NETLINK] af_netlink: kill some bloat
Date: Sat, 12 Jan 2008 11:40:14 +0200
Message-ID: <1200130817405-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54395 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761246AbYALJkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:20 -0500
In-Reply-To: <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/netlink/af_netlink.c:
  netlink_realloc_groups        |  -46
  netlink_insert                |  -49
  netlink_autobind              |  -94
  netlink_clear_multicast_users |  -48
  netlink_bind                  |  -55
  netlink_setsockopt            |  -54
  netlink_release               |  -86
  netlink_kernel_create         |  -47
  netlink_change_ngroups        |  -56
 9 functions changed, 535 bytes removed, diff: -535

net/netlink/af_netlink.c:
  netlink_table_ungrab |  +53
 1 function changed, 53 bytes added, diff: +53

net/netlink/af_netlink.o:
 10 functions changed, 53 bytes added, 535 bytes removed, diff: -482

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index be07f1b..21f9e30 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -193,7 +193,7 @@ static void netlink_table_grab(void)
 	}
 }
=20
-static inline void netlink_table_ungrab(void)
+static void netlink_table_ungrab(void)
 	__releases(nl_table_lock)
 {
 	write_unlock_irq(&nl_table_lock);
--=20
1.5.0.6

