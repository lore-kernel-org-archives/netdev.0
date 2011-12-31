From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: avoid use of implicit declarations
Date: Sat, 31 Dec 2011 23:22:05 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1112312321370.6978@frira.zrqbmnf.qr>
References: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:50040 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251Ab1LaWWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Dec 2011 17:22:07 -0500
In-Reply-To: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: 2011-12-31 23:16:27.428349795 +0100

gcc -DLIBDIR=\"/usr/lib64\" -D_GNU_SOURCE -fmessage-length=0 -O2 -Wall -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -g -Wstrict-prototypes -fPIC -DXT_LIB_DIR=\"/usr/lib64/xtables\" -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib64\" -fPIC   -c -o ipx_pton.o ipx_pton.c
In file included from ../include/utils.h:8:0,
                 from ipx_ntop.c:5:
../include/libnetlink.h: In function 'rta_getattr_u64':
../include/libnetlink.h:84:2: warning: implicit declaration of function 'memcpy'
../include/libnetlink.h:84:2: warning: incompatible implicit declaration of built-in function 'memcpy'

diff --git a/include/libnetlink.h b/include/libnetlink.h
index b237579..b0656ce 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -1,6 +1,7 @@
 #ifndef __LIBNETLINK_H__
 #define __LIBNETLINK_H__ 1
 
+#include <string.h>
 #include <asm/types.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
