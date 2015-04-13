From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 5/7] ip-route: don't hide routes with RTM_F_CLONED by default
Date: Mon, 13 Apr 2015 16:00:59 +0200
Message-ID: <1428933661-8193-5-git-send-email-pavlix@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47551 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754155AbbDMOKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:03 -0400
In-Reply-To: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 024d401..46c24bb 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -144,7 +144,7 @@ static int filter_nlmsg(struct nlmsghdr *n, struct =
rtattr **tb, int host_len)
 	if (r->rtm_family =3D=3D AF_INET6 && table !=3D RT_TABLE_MAIN)
 		ip6_multiple_tables =3D 1;
=20
-	if (filter.cloned =3D=3D !(r->rtm_flags&RTM_F_CLONED))
+	if (filter.cloned && !(r->rtm_flags&RTM_F_CLONED))
 		return 0;
=20
 	if (r->rtm_family =3D=3D AF_INET6 && !ip6_multiple_tables) {
--=20
2.3.5
