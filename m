From: Cosmin Stanescu <cosmin90stanescu@gmail.com>
Subject: [PATCH v2] net: strict_strtoul is obsolete, use kstrtoul instead
Date: Fri, 12 Jul 2013 09:33:33 +0300
Message-ID: <1373610813-11229-1-git-send-email-cosmin90stanescu@gmail.com>
Cc: sergei.shtylyov@cogentembedded.com, dhowells@redhat.com,
	ebiederm@xmission.com, rusty@rustcorp.com.au,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	Cosmin Stanescu <cosmin90stanescu@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:38066 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017Ab3GLGdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 02:33:49 -0400
Received: by mail-ea0-f171.google.com with SMTP id m14so6131987eaj.2
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 23:33:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patch found using checkpatch.pl

Signed-off-by: Cosmin Stanescu <cosmin90stanescu@gmail.com>
---
Changes since v1:
	* fixed user-name in commit message
 net/dns_resolver/dns_key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index 0a69d07..f347a2c 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -118,7 +118,7 @@ dns_resolver_instantiate(struct key *key, struct key_preparsed_payload *prep)
 				if (opt_vlen <= 0)
 					goto bad_option_value;
 
-				ret = strict_strtoul(eq, 10, &derrno);
+				ret = kstrtoul(eq, 10, &derrno);
 				if (ret < 0)
 					goto bad_option_value;
 
-- 
1.7.10.4
