From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: remove unused kernel_stat fields
Date: Tue, 9 Apr 2002 14:02:30 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.33L2.0204091358030.22258-100000@dragon.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: <davem@redhat.com>
List-Id: netdev.vger.kernel.org


Dave, anyone-

I can't find any references to these fields in struct kernel_stat.
Can they be removed...or is there non-kernel code that needs to
have them in the kernel?


Patch against 2.5.8-pre2.  Please apply.


--- linux-258-pre2/include/linux/kernel_stat.h.STAT	Tue Apr  9 12:43:14 2002
+++ linux-258-pre2/include/linux/kernel_stat.h	Tue Apr  9 13:40:51 2002
@@ -29,9 +29,6 @@
 #if !defined(CONFIG_ARCH_S390)
 	unsigned int irqs[NR_CPUS][NR_IRQS];
 #endif
-	unsigned int ipackets, opackets;
-	unsigned int ierrors, oerrors;
-	unsigned int collisions;
 };

 extern struct kernel_stat kstat;


-- 
~Randy

