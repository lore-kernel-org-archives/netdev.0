From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/23] netfilter: ebtables: use __u64 from linux/types.h
Date: Fri, 18 Dec 2015 21:26:27 +0100
Message-ID: <1450470409-31427-2-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57790 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965049AbbLRUdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:33:53 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 27F4E102273
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:52 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D612CDA86C
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:51 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 827184CA08
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:36 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Mikko Rapeli <mikko.rapeli@iki.fi>

=46ixes userspace compilation error:

linux/netfilter_bridge/ebtables.h:38:2: error: unknown type name =E2=80=
=98uint64_t=E2=80=99

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter_bridge/ebtables.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter_bridge/ebtables.h b/include/u=
api/linux/netfilter_bridge/ebtables.h
index fd2ee50..e3cdf9f 100644
--- a/include/uapi/linux/netfilter_bridge/ebtables.h
+++ b/include/uapi/linux/netfilter_bridge/ebtables.h
@@ -12,6 +12,8 @@
=20
 #ifndef _UAPI__LINUX_BRIDGE_EFF_H
 #define _UAPI__LINUX_BRIDGE_EFF_H
+#include <linux/types.h>
+#include <linux/if.h>
 #include <linux/netfilter_bridge.h>
=20
 #define EBT_TABLE_MAXNAMELEN 32
@@ -33,8 +35,8 @@ struct xt_match;
 struct xt_target;
=20
 struct ebt_counter {
-	uint64_t pcnt;
-	uint64_t bcnt;
+	__u64 pcnt;
+	__u64 bcnt;
 };
=20
 struct ebt_replace {
--=20
2.1.4
