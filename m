From: Jiri Olsa <jolsa@redhat.com>
Subject: [PATCH 2/2] man - IP_NODEFRAG option for IPv4 socket
Date: Tue, 15 Jun 2010 13:07:32 +0200
Message-ID: <1276600052-16499-3-git-send-email-jolsa@redhat.com>
References: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-man@vger.kernel.org, Jiri Olsa <jolsa@redhat.com>
To: eric.dumazet@gmail.com, jengelh@medozas.de, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757469Ab0FOLHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 07:07:51 -0400
In-Reply-To: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

this patch adds description for IP_NODEFRAG option for IPv4 socket.

wbr,
jirka


Signed-off-by: Jiri Olsa <jolsa@redhat.com>
---
 man7/ip.7 |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/man7/ip.7 b/man7/ip.7
index 34f7e80..12c0d5b 100644
--- a/man7/ip.7
+++ b/man7/ip.7
@@ -705,6 +705,12 @@ socket option (see
 .BR IP_TTL " (since Linux 1.0)"
 Set or retrieve the current time-to-live field that is used in every packet
 sent from this socket.
+.TP
+.BR IP_NODEFRAG " (since Linux 2.6)"
+If enabled, the reassembly of outgoing packets is disabled in the netfilter layer.
+Only valid for
+.B SOCK_RAW
+sockets.
 .\" FIXME Document IP_XFRM_POLICY
 .\" Since Linux 2.5.48
 .\" Needs CAP_NET_ADMIN
