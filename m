From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] MAINTAINERS: update the NetLabel and Labeled Networking
 information
Date: Thu, 10 Aug 2017 15:13:18 -0400
Message-ID: <150239239837.19177.4190318681371376062.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33166 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752639AbdHJTNK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 15:13:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>

Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 MAINTAINERS |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 65990909fe73..be25ebaaeec3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9112,15 +9112,6 @@ F:	net/*/netfilter/
 F:	net/netfilter/
 F:	net/bridge/br_netfilter*.c
 
-NETLABEL
-M:	Paul Moore <paul@paul-moore.com>
-W:	http://netlabel.sf.net
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	Documentation/netlabel/
-F:	include/net/netlabel.h
-F:	net/netlabel/
-
 NETROM NETWORK LAYER
 M:	Ralf Baechle <ralf@linux-mips.org>
 L:	linux-hams@vger.kernel.org
@@ -9248,10 +9239,23 @@ F:	net/ipv6/
 F:	include/net/ip*
 F:	arch/x86/net/*
 
-NETWORKING [LABELED] (NetLabel, CIPSO, Labeled IPsec, SECMARK)
+NETWORKING [LABELED] (NetLabel, Labeled IPsec, SECMARK)
 M:	Paul Moore <paul@paul-moore.com>
+W:	https://github.com/netlabel
 L:	netdev@vger.kernel.org
+L:	linux-security-module@vger.kernel.org
 S:	Maintained
+F:	Documentation/netlabel/
+F:	include/net/calipso.h
+F:	include/net/cipso_ipv4.h
+F:	include/net/netlabel.h
+F:	include/uapi/linux/netfilter/xt_SECMARK.h
+F:	include/uapi/linux/netfilter/xt_CONNSECMARK.h
+F:	net/netlabel/
+F:	net/ipv4/cipso_ipv4.c
+F:	net/ipv6/calipso.c
+F:	net/netfilter/xt_CONNSECMARK.c
+F:	net/netfilter/xt_SECMARK.c
 
 NETWORKING [TLS]
 M:	Ilya Lesokhin <ilyal@mellanox.com>
