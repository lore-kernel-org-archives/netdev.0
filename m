From: Ben Greear <greearb@candelatech.com>
Subject: PATCH:  Add comment to make finding the priv_flags definition easier.
Date: Tue, 05 Aug 2003 17:24:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F304AC7.6070808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This helps me, at least, remember where the definitions are at!


--- linux-2.4.21/include/linux/netdevice.h	2003-06-13 07:51:38.000000000 -0700
+++ linux-2.4.21.amds/include/linux/netdevice.h	2003-07-30 16:27:20.000000000 -0700
@@ -296,7 +296,9 @@

  	unsigned short		flags;	/* interface flags (a la BSD)	*/
  	unsigned short		gflags;
-        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
+        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace,
+                                             * see: if.h for flag definitions.
+                                             */
          unsigned short          unused_alignment_fixer; /* Because we need priv_flags,
                                                           * and we want to be 32-bit aligned.
                                                           */
-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
