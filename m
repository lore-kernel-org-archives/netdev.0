From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Thu, 31 Oct 2002 12:55:15 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031.125515.108721967.yoshfuji@linux-ipv6.org>
References: <20021031.124459.66300488.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <20021031.124459.66300488.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021031.124459.66300488.yoshfuji@linux-ipv6.org> (at Thu, 31 Oct 2002 12:44:59 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Credit: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>

Oops, I've forgot to credit myself in the source.
Please apply on top of the patch.

Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.4.6.1
retrieving revision 1.1.1.4.6.2
diff -u -r1.1.1.4.6.1 -r1.1.1.4.6.2
--- net/ipv6/addrconf.c	30 Oct 2002 18:15:04 -0000	1.1.1.4.6.1
+++ net/ipv6/addrconf.c	31 Oct 2002 03:50:36 -0000	1.1.1.4.6.2
@@ -28,6 +28,8 @@
  *						packets.
  *	YOSHIFUJI Hideaki @USAGI	:	improved accuracy of
  *						address validation timer.
+ *	YOSHIFUJI Hideaki @USAGI	:	Privacy Extensions (RFC3041)
+ *						support.
  */
 
 #include <linux/config.h>

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
