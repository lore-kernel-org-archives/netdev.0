From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] NET: typo in include/linux/skbuff.h
Date: Wed, 31 Dec 2003 22:05:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231.220533.102712852.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.  I found wrong description in include/linux/skbuff.h.

D: Fix description for skb_dequeue_tail().

Thanks.

===== skbuff.h 1.35 vs edited =====
--- 1.35/include/linux/skbuff.h	Thu Oct  9 00:39:36 2003
+++ edited/skbuff.h	Wed Dec 31 22:00:34 2003
@@ -764,10 +764,10 @@
 }
 
 /**
- *	skb_dequeue - remove from the head of the queue
+ *	skb_dequeue_tail - remove from the tail of the queue
  *	@list: list to dequeue from
  *
- *	Remove the head of the list. The list lock is taken so the function
+ *	Remove the tail of the list. The list lock is taken so the function
  *	may be used safely with other locking list functions. The tail item is
  *	returned or %NULL if the list is empty.
  */

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
