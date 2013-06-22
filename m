From: nirinA raseliarison <nirina.raseliarison@gmail.com>
Subject: if_bridge.h:183:20: error: field 'ip6' has incomplete type
Date: Sun, 23 Jun 2013 02:09:22 +0300
Message-ID: <op.wy3rxwht9ey1ta@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:37517 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab3FVXJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 19:09:11 -0400
Received: by mail-wg0-f46.google.com with SMTP id c11so7275700wgh.13
        for <netdev@vger.kernel.org>; Sat, 22 Jun 2013 16:09:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello there,
i got the errors below when building brigde-utils-1.5.
adding "in6.h" to "if_bridge.h" apparently solve them;
but i would be happy if someone can advise me to build
bridge-utils and the correct fix for these issues.

thanks,

-------------8<----------------------8<-------------------------------------

In file included from libbridge.h:24:0,
                  from libbridge_devif.c:28:
/usr/include/linux/if_bridge.h:183:20: error: field 'ip6' has incomplete  
type
     struct in6_addr ip6;
                     ^
In file included from libbridge.h:24:0,
                  from libbridge_if.c:26:
/usr/include/linux/if_bridge.h:183:20: error: field 'ip6' has incomplete  
type
     struct in6_addr ip6;
                     ^
In file included from libbridge.h:24:0,
                  from libbridge_init.c:28:
/usr/include/linux/if_bridge.h:183:20: error: field 'ip6' has incomplete  
type
     struct in6_addr ip6;
                     ^
In file included from libbridge.h:24:0,
                  from libbridge_misc.c:24:
/usr/include/linux/if_bridge.h:183:20: error: field 'ip6' has incomplete  
type
     struct in6_addr ip6;
                     ^
[...]

gcc -Wall -O2 -fPIC -I../libbridge -I/usr/src/linux/include  -c brctl.c
In file included from ../libbridge/libbridge.h:24:0,
                  from brctl.c:25:
/usr/include/linux/if_bridge.h:183:20: error: field 'ip6' has incomplete  
type
     struct in6_addr ip6;
                     ^
-------------8<----------------------8<-------------------------------------
diff -u include/uapi/linux/if_bridge_orig.h include/uapi/linux/if_bridge.h
--- include/uapi/linux/if_bridge_orig.h 2013-06-23 03:55:34.072971125 +0300
+++ include/uapi/linux/if_bridge.h      2013-06-23 03:55:45.676970995 +0300
@@ -14,6 +14,7 @@
  #define _UAPI_LINUX_IF_BRIDGE_H

  #include <linux/types.h>
+#include <linux/in6.h>

  #define SYSFS_BRIDGE_ATTR      "bridge"
  #define SYSFS_BRIDGE_FDB       "brforward"
-------------8<----------------------8<-------------------------------------


--
nirinA
