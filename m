From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/2] linux/times.h needs asm/param.h
Date: Sun, 09 Nov 2003 15:59:25 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109.155925.112987543.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[1/1] linux/times.h needs asm/param.h

linux/times.h depends on asm/param.h (USER_HZ).

===== include/linux/times.h 1.4 vs edited =====
--- 1.4/include/linux/times.h	Fri Jul 18 01:54:48 2003
+++ edited/include/linux/times.h	Mon Nov 10 06:34:07 2003
@@ -4,6 +4,7 @@
 #ifdef __KERNEL__
 #include <asm/div64.h>
 #include <asm/types.h>
+#include <asm/param.h>
 
 #if (HZ % USER_HZ)==0
 # define jiffies_to_clock_t(x) ((x) / (HZ / USER_HZ))

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
