From: Matt Domsch <Matt_Domsch@dell.com>
Subject: [PATCH 2.4.30-pre3] net/{icmp,ipv6}.h: include net/snmp.h
Date: Fri, 18 Mar 2005 15:22:56 -0600
Message-ID: <20050318212256.GB26112@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Compiling linux-2.4.30-pre3 with FC4-test1 compiler gcc-4.0.0-0.32 on
x86_64 fails because icmp_statistics[NR_CPUS*2] is declared as a sized
array without struct icmp_mib having been defined, likewise
ipv6_statistics[NR_CPUS*2] without struct ipv6_mib first defined.

Solution is to include <net/snmp.h> before declaring either array.

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

===== include/net/icmp.h 1.2 vs edited =====
--- 1.2/include/net/icmp.h	2002-02-05 01:39:17 -06:00
+++ edited/include/net/icmp.h	2005-03-18 15:11:59 -06:00
@@ -23,6 +23,7 @@
 
 #include <net/sock.h>
 #include <net/protocol.h>
+#include <net/snmp.h>
 
 struct icmp_err {
   int		errno;
===== include/net/ipv6.h 1.9 vs edited =====
--- 1.9/include/net/ipv6.h	2004-07-15 15:33:03 -05:00
+++ edited/include/net/ipv6.h	2005-03-18 15:13:13 -06:00
@@ -19,6 +19,7 @@
 #include <asm/hardirq.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
+#include <net/snmp.h>
 
 #define SIN6_LEN_RFC2133	24
 
