From: paul.moore@hp.com
Subject: [PATCH v2 4/8] Netlink: add nla_for_each_nested() to the interface list
Date: Mon, 25 Sep 2006 14:04:16 -0400
Message-ID: <20060925180641.353879000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:13216 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751412AbWIYSGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:44 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlink-missing_comment
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the top of include/net/netlink.h is a list of Netlink interfaces, however,
the nla_for_each_nested() macro was not listed.  This patch adds this interface
to the list at the top of the header file.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/netlink.h |    1 +
 1 files changed, 1 insertion(+)

Index: net-2.6.19/include/net/netlink.h
===================================================================
--- net-2.6.19.orig/include/net/netlink.h
+++ net-2.6.19/include/net/netlink.h
@@ -151,6 +151,7 @@
  *   nla_parse()			parse and validate stream of attrs
  *   nla_parse_nested()			parse nested attribuets
  *   nla_for_each_attr()		loop over all attributes
+ *   nla_for_each_nested()		loop over the nested attributes
  *=========================================================================
  */
 

--
paul moore
linux security @ hp
