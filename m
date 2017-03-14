From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] lwtunnel: remove unused but set variable
Date: Mon, 13 Mar 2017 23:04:48 -0700
Message-ID: <1489471488-12341-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35220 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdCNGEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 02:04:54 -0400
Received: by mail-pg0-f44.google.com with SMTP id b129so80069703pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 23:04:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

silences the below warning:
net/core/lwtunnel.c: In function ‘lwtunnel_valid_encap_type_attr’:
net/core/lwtunnel.c:165:17: warning: variable ‘nla’ set but not used
[-Wunused-but-set-variable]

Fixes: 9ed59592e3e3 ("lwtunnel: fix autoload of lwt modules")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/lwtunnel.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 6df9f8f..b588819 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -162,7 +162,6 @@ int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining)
 	struct rtnexthop *rtnh = (struct rtnexthop *)attr;
 	struct nlattr *nla_entype;
 	struct nlattr *attrs;
-	struct nlattr *nla;
 	u16 encap_type;
 	int attrlen;
 
@@ -170,7 +169,6 @@ int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining)
 		attrlen = rtnh_attrlen(rtnh);
 		if (attrlen > 0) {
 			attrs = rtnh_attrs(rtnh);
-			nla = nla_find(attrs, attrlen, RTA_ENCAP);
 			nla_entype = nla_find(attrs, attrlen, RTA_ENCAP_TYPE);
 
 			if (nla_entype) {
-- 
1.9.1
