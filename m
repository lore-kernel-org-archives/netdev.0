From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] IPv6 IPsec AH typo
Date: Thu, 15 Apr 2004 21:02:23 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040415210223.24aabc4a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

this patch fixes a typo. Please apply it.

Thanks,

--- linux-2.6.5.orig/net/ipv6/ah6.c	Sun Apr  4 12:37:36 2004
+++ linux-2.6.5/net/ipv6/ah6.c	Thu Apr 15 20:38:48 2004
@@ -162,7 +162,7 @@
 	}
 
 	spin_lock_bh(&x->lock);
-	err = xfrm_check_output(x, skb, AF_INET);
+	err = xfrm_check_output(x, skb, AF_INET6);
 	if (err)
 		goto error;
 



-- 
Masahide NAKAMURA
