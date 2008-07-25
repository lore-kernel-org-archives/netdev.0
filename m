From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/3] net: drop unused BUG_TRAP()
Date: Fri, 25 Jul 2008 15:47:00 +0300
Message-ID: <1216990020-2716-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1216990020-2716-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33532 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbYGYMre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:47:34 -0400
In-Reply-To: <1216990020-2716-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/rtnetlink.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index f4d386c..ca643b1 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -755,13 +755,6 @@ extern void __rtnl_unlock(void);
 	} \
 } while(0)
=20
-#define BUG_TRAP(x) do { \
-	if (unlikely(!(x))) { \
-		printk(KERN_ERR "KERNEL: assertion (%s) failed at %s (%d)\n", \
-			#x,  __FILE__ , __LINE__); \
-	} \
-} while(0)
-
 static inline u32 rtm_get_table(struct rtattr **rta, u8 table)
 {
 	return RTA_GET_U32(rta[RTA_TABLE-1]);
--=20
1.5.2.2

