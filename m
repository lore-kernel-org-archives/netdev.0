From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2/2] iproute2: update ip-l2tp man page
Date: Tue, 26 Mar 2013 16:49:23 +0000
Message-ID: <1364316563-23303-2-git-send-email-jchapman@katalix.com>
References: <1364316563-23303-1-git-send-email-jchapman@katalix.com>
Cc: tlund@nxs.se, James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36404 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab3CZQti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 12:49:38 -0400
In-Reply-To: <1364316563-23303-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation about the new l2spec_type parameter for "ip l2tp add
session".

Signed-off-by: James Chapman <jchapman@katalix.com>
---
:100644 100644 2df7ce2... 463878f... M	man/man8/ip-l2tp.8
 man/man8/ip-l2tp.8 |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 2df7ce2..463878f 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -52,6 +52,8 @@ ip-l2tp - L2TPv3 static unmanaged tunnel configuration
 .IR HEXSTR
 .RB " ]"
 .br
+.RB "[ " l2spec_type " { " none " | " default " } ]"
+.br
 .RB "[ " offset
 .IR OFFSET
 .RB " ] [ " peer_offset
@@ -239,6 +241,12 @@ e.g. 014d3636deadbeef. The value must match the cookie value set at
 the peer. It tells the local system what cookie value to expect to
 find in received L2TP packets. Default is to use no cookie.
 .TP
+.BI l2spec_type " L2SPECTYPE"
+set the layer2specific header type of the session.
+.br
+Valid values are:
+.BR none ", " udp "."
+.TP
 .BI offset " OFFSET"
 sets the byte offset from the L2TP header where user data starts in
 transmitted L2TP data packets. This is hardly ever used. If set, the
@@ -368,6 +376,12 @@ tunnels. Hello messages are used by L2TP clients and servers to detect
 link failures in order to automate tearing down and reestablishing
 dynamic tunnels. If a non-Linux peer supports Hello messages in
 unmanaged tunnels, it must be turned off to interoperate with Linux.
+.PP
+Linux defaults to use the Default Layer2SpecificHeader type as defined
+in the L2TPv3 protocol specification, RFC3931. This setting must be
+consistent with that configured at the peer. Some vendor
+implementations (e.g. Cisco) default to use a Layer2SpecificHeader
+type of None.
 .SH SEE ALSO
 .br
 .BR ip (8)
-- 
1.7.9.5
