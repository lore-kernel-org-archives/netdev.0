From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH 08/10] ss: symmetrical subhandler output extension example
Date: Mon, 10 Aug 2015 20:52:22 +0200
Message-ID: <1439232744-19505-9-git-send-email-matthias.tafelmeier@gmx.net>
References: <1439232744-19505-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:62473 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932599AbbHJSxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 14:53:06 -0400
In-Reply-To: <1439232744-19505-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small sized patch shall convey the locations which have to be
changed for a symmetrical output extension. Symmetrical means in this
context all existing semantically related handlers in the diverse
formatters (for hr and json up to now).

Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 misc/ss_hr_fmt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/misc/ss_hr_fmt.c b/misc/ss_hr_fmt.c
index 6955ea5..40b6b7c 100644
--- a/misc/ss_hr_fmt.c
+++ b/misc/ss_hr_fmt.c
@@ -82,6 +82,8 @@ static void tcp_stats_hr_fmt(struct tcpstat *s)
 		printf(" reordering:%d", s->reordering);
 	if (s->rcv_rtt)
 		printf(" rcv_rtt:%g", s->rcv_rtt);
+	if (s->rcv_space)
+		printf(" rcv_space:%d", s->rcv_space);
 
 	CHECK_FMT_ADAPT(s->rcv_space, s,
 	hr_handler_must_be_adapted_accordingly_when_json_fmt_is_extended);
-- 
1.9.1
