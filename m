From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Mark SIOCSIFNAME as compatible ioctl
Date: Thu, 8 Jan 2004 08:04:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108070413.GA31778@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Mark SIOCSIFNAME as an ioctl that doesn't need 32bit conversion.

Fixes nameif as 32bit executable.

-Andi

diff -X ../KDIFX -burpN linux-vanilla-2.6.1rc2/include/linux/compat_ioctl.h linux-2.6.1rc2-amd64/include/linux/compat_ioctl.h
--- linux-vanilla-2.6.1rc2/include/linux/compat_ioctl.h	2004-01-07 02:36:31.000000000 -0800
+++ linux-2.6.1rc2-amd64/include/linux/compat_ioctl.h	2003-12-31 21:56:55.000000000 -0800
@@ -260,6 +260,7 @@ COMPATIBLE_IOCTL(SIOCATMARK)
 COMPATIBLE_IOCTL(SIOCSIFLINK)
 COMPATIBLE_IOCTL(SIOCSIFENCAP)
 COMPATIBLE_IOCTL(SIOCGIFENCAP)
+COMPATIBLE_IOCTL(SIOCSIFNAME)
 COMPATIBLE_IOCTL(SIOCSIFBR)
 COMPATIBLE_IOCTL(SIOCGIFBR)
 COMPATIBLE_IOCTL(SIOCSARP)
