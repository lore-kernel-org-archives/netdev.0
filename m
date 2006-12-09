From: Thomas Graf <tgraf@suug.ch>
Subject: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 9 Dec 2006 11:39:53 +0100
Message-ID: <20061209103953.GN8693@postel.suug.ch>
References: <20061208.134752.131916271.davem@davemloft.net> <20061208215206.GA29601@nevyn.them.org> <20061208.164345.71119524.davem@davemloft.net> <20061208.171455.11932070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: drow@false.org, stefan@loplof.de, dwmw2@infradead.org, 	joseph@codesourcery.com, netdev@vger.kernel.org, 	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <libc-alpha-return-19642-glibc-alpha=m.gmane.org@sourceware.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061208.171455.11932070.davem@davemloft.net>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/Documentation/feature-removal-schedule.txt
===================================================================
--- net-2.6.orig/Documentation/feature-removal-schedule.txt	2006-12-09 11:29:25.000000000 +0100
+++ net-2.6/Documentation/feature-removal-schedule.txt	2006-12-09 11:37:54.000000000 +0100
@@ -6,6 +6,18 @@ be removed from this file.
 
 ---------------------------
 
+What:	Netlink message and attribute parsing macros
+When:	July 2007
+Why:	The old interface which often lead to buggy code has been replaced
+	with a new type safe interface. Parts of this interface, mainly
+	macros, has been exported to userspace via linux/netlink.h and
+	linux/rtnetlink.h. Use of this interface is discontinued, all helper
+	and utility macros will be removed. Userspace applications should use
+	one of the available libraries.
+Who:	Thomas Graf <tgraf@suug.ch>
+
+---------------------------
+
 What:	/sys/devices/.../power/state
 	dev->power.power_state
 	dpm_runtime_{suspend,resume)()
