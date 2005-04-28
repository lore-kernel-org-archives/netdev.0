From: Andrew Grover <andy.grover@gmail.com>
Subject: [PATCH] Add more explanation to tcp_prequeue comment
Date: Thu, 28 Apr 2005 14:14:13 -0700
Message-ID: <c0a09e5c05042814145901639e@mail.gmail.com>
Reply-To: Andrew Grover <andy.grover@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here's a patch to make that prequeue comment a little clearer. Look ok?

Signed-off-by: Andy Grover <andrew.grover@intel.com>

===== include/net/tcp.h 1.105 vs edited =====
--- 1.105/include/net/tcp.h     2005-02-22 10:45:31 -08:00
+++ edited/include/net/tcp.h    2005-04-28 14:02:43 -07:00
@@ -1560,6 +1560,13 @@
  * idea (VJ's mail "Re: query about TCP header on tcp-ip" of 07 Sep 93)
  * failed somewhere. Latency? Burstiness? Well, at least now we will
  * see, why it failed. 8)8)                              --ANK
+ *
+ * Actually, even though the prequeue is not as important for fast
+ * csum anymore, it is important for scheduling, to generate ACKs
+ * when the data is received by the process, not the stack.
+ * davem says, "Without prequeue, we ACK immediately. This artificially
+ * makes the sender believe it can pump data out at that rate to the
+ * receiver."
  *
  * NOTE: is this not too big to inline?
  */
