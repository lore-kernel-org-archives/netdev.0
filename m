From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv4: remove fib_lookup.h from devinet.c include list
Date: Wed,  1 Feb 2017 18:41:25 -0800
Message-ID: <1486003285-2146-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34744 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdBBCld (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:41:33 -0500
Received: by mail-pg0-f45.google.com with SMTP id 14so1231343pgg.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:41:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nothing in devinet.c relies on fib_lookup.h; remove it from the includes

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/devinet.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 4cd2ee8857d2..5d367b7ff542 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -65,8 +65,6 @@
 #include <net/net_namespace.h>
 #include <net/addrconf.h>
 
-#include "fib_lookup.h"
-
 static struct ipv4_devconf ipv4_devconf = {
 	.data = {
 		[IPV4_DEVCONF_ACCEPT_REDIRECTS - 1] = 1,
-- 
2.1.4
