From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] MLDV2: Use IANA icmpv6 type for MLDv2 Report
Date: Thu, 15 Apr 2004 07:33:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040415.073324.44957072.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

IANA has finally assigned an ICMPv6 type for MLDv2 Report.
(See: <http://www.iana.org/assignments/icmpv6-parameters>)

Patch also applies to 2.4.

Thanks.

===== include/linux/icmpv6.h 1.3 vs edited =====
--- 1.3/include/linux/icmpv6.h	Wed Apr 16 17:45:42 2003
+++ edited/include/linux/icmpv6.h	Thu Apr 15 07:30:09 2004
@@ -95,8 +95,7 @@
 #define MLD2_ALLOW_NEW_SOURCES	5
 #define MLD2_BLOCK_OLD_SOURCES	6
 
-/* this must be an IANA-assigned value; 206 for testing only */
-#define ICMPV6_MLD2_REPORT		206
+#define ICMPV6_MLD2_REPORT		143
 #define MLD2_ALL_MCR_INIT { { { 0xff,0x02,0,0,0,0,0,0,0,0,0,0,0,0,0,0x16 } } }
 
 /*



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
