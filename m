From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 v2 9/9] man: ip-l2tp.8: document UDP checksum options
Date: Wed, 16 Nov 2016 22:45:26 +0000
Message-ID: <20161116224526.32343-9-asbjorn@asbjorn.st>
References: <20161116224526.32343-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:33040 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941350AbcKPWqi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 17:46:38 -0500
In-Reply-To: <20161116224526.32343-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 man/man8/ip-l2tp.8 | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index d4e7270..8ce630a 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -30,6 +30,12 @@ ip-l2tp - L2TPv3 static unmanaged tunnel configuration
 .IR PORT
 .RB " ]"
 .br
+.RB "[ " udp_csum " { " on " | " off " } ]"
+.br
+.RB "[ " udp6_csum_tx " { " on " | " off " } ]"
+.br
+.RB "[ " udp6_csum_rx " { " on " | " off " } ]"
+.br
 .ti -8
 .BR "ip l2tp add session"
 .RB "[ " name
@@ -190,6 +196,33 @@ selected.
 set the UDP destination port to be used for the tunnel. Must be
 present when udp encapsulation is selected. Ignored when ip
 encapsulation is selected.
+.TP
+.BI udp_csum " STATE"
+(IPv4 only) control if IPv4 UDP checksums should be calculated and checked for the
+encapsulating UDP packets, when UDP encapsulating is selected.
+Default is
+.BR off "."
+.br
+Valid values are:
+.BR on ", " off "."
+.TP
+.BI udp6_csum_tx " STATE"
+(IPv6 only) control if IPv6 UDP checksums should be calculated for encapsulating
+UDP packets, when UDP encapsulating is selected.
+Default is
+.BR on "."
+.br
+Valid values are:
+.BR on ", " off "."
+.TP
+.BI udp6_csum_rx " STATE"
+(IPv6 only) control if IPv6 UDP checksums should be checked for the encapsulating
+UDP packets, when UDP encapsulating is selected.
+Default is
+.BR on "."
+.br
+Valid values are:
+.BR on ", " off "."
 .SS ip l2tp del tunnel - destroy a tunnel
 .TP
 .BI tunnel_id " ID"
-- 
2.10.2
