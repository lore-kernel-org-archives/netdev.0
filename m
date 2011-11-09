From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] libteam: fix function names to include 'bond'
Date: Wed,  9 Nov 2011 16:20:46 -0200
Message-ID: <1320862846-6000-1-git-send-email-fbl@redhat.com>
References: <1319660867-945-1-git-send-email-jpirko@redhat.com>
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com,
	Flavio Leitner <fbl@redhat.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab1KISVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 13:21:17 -0500
In-Reply-To: <1319660867-945-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---

 I found those while trying to test V6 patch using latest
 libteam (commit 5e9790816606a6dd4e7f6f32c0bb0c45e5d13b31)
 and libnl-3.2.2 (last stable).
 thanks,
 fbl

 lib/libteam.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/libteam.c b/lib/libteam.c
index feb13b6..e7ae6b0 100644
--- a/lib/libteam.c
+++ b/lib/libteam.c
@@ -1331,7 +1331,7 @@ int team_port_add(struct team_handle *th, uint32_t port_ifindex)
 {
 	int err;
 
-	err = rtnl_link_enslave_ifindex(th->nl_cli.sock, th->ifindex,
+	err = rtnl_link_bond_enslave_ifindex(th->nl_cli.sock, th->ifindex,
 					port_ifindex);
 	return -nl2syserr(err);
 }
@@ -1350,6 +1350,6 @@ int team_port_remove(struct team_handle *th, uint32_t port_ifindex)
 {
 	int err;
 
-	err = rtnl_link_release_ifindex(th->nl_cli.sock, port_ifindex);
+	err = rtnl_link_bond_release_ifindex(th->nl_cli.sock, port_ifindex);
 	return -nl2syserr(err);
 }
-- 
1.7.6
