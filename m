From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: CONFIG_IPV6 Documentation update
Date: Wed, 29 Oct 2003 00:35:36 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029.003536.91692593.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

CONFIG_IPV6 Documentation update.

Specifically, there are no descriptions on net-tools in 
Documentation/Changes.

Thanks.

===== net/Kconfig 1.26 vs edited =====
--- 1.26/net/Kconfig	Sun Oct  5 15:50:47 2003
+++ edited/net/Kconfig	Wed Oct 29 00:31:40 2003
@@ -120,8 +120,10 @@
 	tristate "The IPv6 protocol (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
 	---help---
-	  This is experimental support for the next version of the Internet
-	  Protocol: IP version 6 (also called IPng "IP next generation").
+	  This is experimental support for the IP version 6 (formerly called
+	  IPng "IP next generation").  You will still be able to do
+	  regular IPv4 networking as well.
+
 	  Features of this new protocol include: expanded address space,
 	  authentication and privacy, and seamless interoperability with the
 	  current version of IP (IP version 4). For general information about
@@ -130,12 +132,10 @@
 	  <http://www.bieringer.de/linux/IPv6/> and the file net/ipv6/README
 	  in the kernel source.
 
-	  If you want to use IPv6, please upgrade to the newest net-tools as
-	  given in <file:Documentation/Changes>. You will still be able to do
-	  regular IPv4 networking as well.
-
-	  To compile this protocol support as a module, choose M here: the
-	  module will be called ipv6.
+	  To compile this protocol support as a module, choose M here: the 
+	  module will be called ipv6.  If you try building this as a module 
+	  and you have said Y to "Kernel module loader support" above, 
+	  be sure to add 'alias net-pf-10 ipv6' to your /etc/modules.conf file.
 
 	  It is safe to say N here for now.
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
