From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.4 patch] CONFIG_NET_SCH_NETEM Configure.help entry
Date: Sun, 1 Aug 2004 16:27:59 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040801142759.GQ2746@fs.tum.de>
References: <20040731142658.GA6497@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265981AbUHAO2K@vger.kernel.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040731142658.GA6497@logos.cnet>
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2004 at 11:26:59AM -0300, Marcelo Tosatti wrote:
>...
> Summary of changes from v2.4.27-rc3 to v2.4.27-rc4
> ============================================
>...
> Stephen Hemminger:
>   o [PKT_SCHED]: Update to network emulation QOS scheduler
>   o [PKT_SCHED]: One small netem fixes
>   o [BRIDGE]: Fix assertion failure in 2.4.27-rc3
>   o [PKT_SCHED]: netem update for 2.4
>...


The Configure.help entry was forgotten:


Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

--- linux-2.4.27-rc4-full/Documentation/Configure.help.old	2004-08-01 16:20:15.000000000 +0200
+++ linux-2.4.27-rc4-full/Documentation/Configure.help	2004-08-01 16:22:23.000000000 +0200
@@ -10949,13 +10949,15 @@
   whenever you want). If you want to compile it as a module, say M
   here and read <file:Documentation/modules.txt>.
 
-Network delay simualtor  
-CONFIG_NET_SCH_DELAY
-  Say Y if you want to delay packets by a fixed amount of
-  time. This is often useful to simulate network delay when
+CONFIG_NET_SCH_NETEM
+  Say Y if you want to emulate network delay, loss, and packet
+  re-ordering. This is often useful to simulate networks when
   testing applications or protocols.
-  
-  This code is also available as a module called sch_delay.o
+
+  To compile this driver as a module, choose M here: the module
+  will be called sch_netem.
+
+  If unsure, say N.
 
 Ingress Qdisc
 CONFIG_NET_SCH_INGRESS
