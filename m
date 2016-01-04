From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH iproute2 4/4] man: iplink: document new addrgenmodes
Date: Mon,  4 Jan 2016 10:58:06 +0100
Message-ID: <1451901486-3497-5-git-send-email-bjorn@mork.no>
References: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:32787 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbcADJ6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 04:58:33 -0500
In-Reply-To: <1451901486-3497-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 man/man8/ip-link.8.in | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index ac6f4813a329..189a8f15fa03 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -150,7 +150,7 @@ ip-link \- network device configuration
 .br
 .B nomaster " |"
 .br
-.B addrgenmode { eui64 | none }
+.B addrgenmode { eui64 | none | stable_secret | random }
 .br
 .B link-netnsid ID
 .BR " }"
@@ -1029,8 +1029,20 @@ set master device of the device (enslave device)=
=2E
 unset master device of the device (release device).
=20
 .TP
-.BR "addrgenmode eui64 " or " addrgenmode none"
-set IPv6 address generation mode
+.BI addrgenmode " eui64|none|stable_secret|random"
+set the IPv6 address generation mode
+
+.I eui64
+- use a Modified EUI-64 format interface identifier
+
+.I none
+- disable automatic address generation
+
+.I stable_secret
+- generate the interface identifier based on a preset /proc/sys/net/ip=
v6/conf/{default,DEVICE}/stable_secret
+
+.I random
+- like stable_secret, but auto-generate a new random secret if none is=
 set
=20
 .TP
 .BR "link-netnsid "
--=20
2.1.4
