From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATH] IPv6 IPsec support
Date: Wed, 05 Mar 2003 15:25:30 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305.152530.70806720.davem@redhat.com>
References: <20030305233025.784feb00.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030305233025.784feb00.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Wed, 5 Mar 2003 23:30:25 +0900

Hello Miyazawa-san,

   I submit the patch to let the kernel support ipv6 ipsec again.
   It is able to comple ipv6 as module.

As promised I applied the patch.  I will push it to Linus later
this evening, or tomorrow.

In this initial checkin I made only 2 minor fixes, they
are attached below:

--- ./include/net/ip6_route.h.~1~	Wed Mar  5 15:32:41 2003
+++ ./include/net/ip6_route.h	Wed Mar  5 15:40:42 2003
@@ -38,7 +38,6 @@
 extern int			ipv6_route_ioctl(unsigned int cmd, void *arg);
 
 extern int			ip6_route_add(struct in6_rtmsg *rtmsg);
-extern int			ip6_route_del(struct in6_rtmsg *rtmsg);
 extern int			ip6_del_rt(struct rt6_info *);
 
 extern int			ip6_rt_addr_add(struct in6_addr *addr,
--- ./net/ipv6/Kconfig.~1~	Wed Mar  5 15:32:41 2003
+++ ./net/ipv6/Kconfig	Wed Mar  5 15:35:27 2003
@@ -19,6 +19,7 @@
 
 config INET6_AH
 	tristate "IPv6: AH transformation"
+	depends on IPV6
 	---help---
 	  Support for IPsec AH.
 
@@ -26,6 +27,7 @@
 
 config INET6_ESP
 	tristate "IPv6: ESP transformation"
+	depends on IPV6
 	---help---
 	  Support for IPsec ESP.
 
