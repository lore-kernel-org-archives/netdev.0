From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: [PATCH] Export a few icmpv6 symbols
Date: Tue, 25 Mar 2003 10:52:26 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E80894A.59C6EB95@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Export a few icmpv6 symbols so SCTP can have at them from its v6
err_handler. 

Thanks,
Jon Grimm

--- linux-2.5.66/net/ipv6/ipv6_syms.c	Tue Mar 25 08:13:07 2003
+++ lksctp-2.5.work/net/ipv6/ipv6_syms.c	Tue Mar 25 10:27:43 2003
@@ -9,6 +9,8 @@
 
 EXPORT_SYMBOL(ipv6_addr_type);
 EXPORT_SYMBOL(icmpv6_send);
+EXPORT_SYMBOL(icmpv6_statistics);
+EXPORT_SYMBOL(icmpv6_err_convert);
 EXPORT_SYMBOL(ndisc_mc_map);
 EXPORT_SYMBOL(register_inet6addr_notifier);
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
