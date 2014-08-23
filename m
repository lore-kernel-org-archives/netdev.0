From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH iproute2] ll_types: add netlink ARPHRD
Date: Sat, 23 Aug 2014 17:13:29 +0200
Message-ID: <1408806809-11593-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbaHWPNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2014 11:13:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds ARPHRD_NETLINK to ll_types so that it can be properly
shown e.g. in `ip a`:

 8: nlmon: <NOARP,UP,LOWER_UP> mtu 3776 qdisc noqueue state UNKNOWN group default
    link/netlink

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/ll_types.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/ll_types.c b/lib/ll_types.c
index 0c39183..2c5bf8b 100644
--- a/lib/ll_types.c
+++ b/lib/ll_types.c
@@ -104,6 +104,7 @@ __PF(PHONET, phonet)
 __PF(PHONET_PIPE, phonet_pipe)
 __PF(CAIF, caif)
 __PF(IP6GRE, gre6)
+__PF(NETLINK, netlink)
 
 __PF(NONE, none)
 __PF(VOID,void)
-- 
1.7.11.7
