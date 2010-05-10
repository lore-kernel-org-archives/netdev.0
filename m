From: Andreas Meissner <andreas.meissner@indakom.de>
Subject: Re: [PATCH] IPv4: unresolved multicast route cleanup
Date: Mon, 10 May 2010 10:40:47 +0200
Message-ID: <4BE7C68F.1040403@indakom.de>
References: <4BDE9BCB.8040803@indakom.de> <20100503.154128.10559786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from indakom.de ([213.133.108.139]:1646 "EHLO www.indakom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753364Ab0EJIk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 04:40:57 -0400
In-Reply-To: <20100503.154128.10559786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> 
> Your email client has corrupted tabs into space characters, and
> the new code in your patch is not indented properly.
> 

2nd try. Indentation should be ok now, hopefully.
---
 ipmr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
--- net/ipv4/ipmr.c.orig	2010-05-10 10:07:38.000000000 +0200
+++ net/ipv4/ipmr.c	2010-05-10 10:08:39.000000000 +0200
@@ -753,7 +753,8 @@
 		c->next = mfc_unres_queue;
 		mfc_unres_queue = c;
 
-		mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
+		if (atomic_read(&net->ipv4.cache_resolve_queue_len) == 1)
+			mod_timer(&ipmr_expire_timer, c->mfc_un.unres.expires);
 	}
 
 	/*

