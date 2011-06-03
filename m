From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/3] include/net: Remove unnecessary semicolons
Date: Fri,  3 Jun 2011 14:51:21 -0700
Message-ID: <9fb8e8d355f718b508f5e5e1093ce877ff66e9e3.1307137352.git.joe@perches.com>
References: <cover.1307137351.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2502 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754256Ab1FCVvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 17:51:22 -0400
Received: from Joe-Laptop.home (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id CDE312436D
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2011 14:51:19 -0700 (PDT)
In-Reply-To: <cover.1307137351.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Semicolons are not necessary after switch/while/for/if braces
so remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/sctp/sctp.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index f9fe374..6a72a58 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -601,7 +601,7 @@ static inline int ipver2af(__u8 ipver)
 		return AF_INET6;
 	default:
 		return 0;
-	};
+	}
 }
 
 /* Convert from an address parameter type to an address family.  */
@@ -614,7 +614,7 @@ static inline int param_type2af(__be16 type)
 		return AF_INET6;
 	default:
 		return 0;
-	};
+	}
 }
 
 /* Perform some sanity checks. */
-- 
1.7.5.rc3.dirty

