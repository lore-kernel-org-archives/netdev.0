From: Alex Pankratov <ap@cipherica.com>
Subject: [PATCH 2.6.1] dst_gc_timer initialization
Date: Mon, 19 Jan 2004 16:14:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400C72CF.9020906@cipherica.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080502050504050300070007"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080502050504050300070007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The second and third parameters of TIMER_INITIALIZER macro, which is 
used to initialize dst_gc_timer, are swapped. The patch puts them into 
the right order.

Alex

--------------080502050504050300070007
Content-Type: text/plain;
 name="dst.c.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dst.c.diff"

--- dst.c	2004-01-19 16:16:41.323996968 -0800
+++ dst.c.patched	2004-01-19 16:16:31.188537792 -0800
@@ -40,7 +40,7 @@
 static void ___dst_free(struct dst_entry * dst);
 
 static struct timer_list dst_gc_timer =
-	TIMER_INITIALIZER(dst_run_gc, 0, DST_GC_MIN);
+	TIMER_INITIALIZER(dst_run_gc, DST_GC_MIN, 0);
 
 static void dst_run_gc(unsigned long dummy)
 {

--------------080502050504050300070007--
