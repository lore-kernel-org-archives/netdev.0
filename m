From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] kernel-api.sgml references removed file net_init.c
Date: Mon, 24 Jan 2005 20:36:24 +0100
Message-ID: <20050124193624.GS3515@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Juhl <juhl-lkml@dif.dk>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch by Jesper Juhl is still required in 2.6.11-rc2-mm1.


make mandocs fails with these errors in 2.6.10-bk2 : 

juhl@dragon:~/download/kernel/linux-2.6.10-bk2$ make mandocs
  DOCPROC Documentation/DocBook/kernel-api.sgml
docproc: /home/juhl/download/kernel/linux-2.6.10-bk2/drivers/net/net_init.c: No such file or directory
/bin/sh: line 1:  4845 Segmentation fault      
SRCTREE=/home/juhl/download/kernel/linux-2.6.10-bk2/ scripts/basic/docproc doc Documentation/DocBook/kernel-api.tmpl >Documentation/DocBook/kernel-api.sgml
make[1]: *** [Documentation/DocBook/kernel-api.sgml] Error 139
make: *** [mandocs] Error 2

removing the reference to net_init.c makes it continue a bit further but 
it still ends up failing with these errors : 

make[1]: *** [Documentation/DocBook/kernel-api.sgml] Error 1
make: *** [mandocs] Error 2

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-bk2-orig/Documentation/DocBook/kernel-api.tmpl	2004-12-24 22:33:48.000000000 +0100
+++ linux-2.6.10-bk2/Documentation/DocBook/kernel-api.tmpl	2004-12-31 01:33:53.000000000 +0100
@@ -143,7 +143,6 @@
   <chapter id="netdev">
      <title>Network device support</title>
      <sect1><title>Driver Support</title>
-!Edrivers/net/net_init.c
 !Enet/core/dev.c
      </sect1>
      <sect1><title>8390 Based Network Cards</title>
