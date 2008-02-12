From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [PATCH] 2.6.25-rc1 ml4x network driver build failure
Date: Tue, 12 Feb 2008 15:12:07 +0530
Message-ID: <20080212094207.GA19427@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761863AbYBLJmZ@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 2.6.25-rc1 kernel build fails on the powerpc with the error

drivers/net/mlx4/alloc.c: In function =E2=80=98mlx4_buf_alloc=E2=80=99:
drivers/net/mlx4/alloc.c:162: error: implicit declaration of function =E2=
=80=98vmap=E2=80=99
drivers/net/mlx4/alloc.c:162: error: =E2=80=98VM_MAP=E2=80=99 undeclare=
d (first use in this function)
drivers/net/mlx4/alloc.c:162: error: (Each undeclared identifier is rep=
orted only once
drivers/net/mlx4/alloc.c:162: error: for each function it appears in.)
drivers/net/mlx4/alloc.c:162: warning: assignment makes pointer from in=
teger without a cast
drivers/net/mlx4/alloc.c: In function =E2=80=98mlx4_buf_free=E2=80=99:
drivers/net/mlx4/alloc.c:187: error: implicit declaration of function =E2=
=80=98vunmap=E2=80=99
make[3]: *** [drivers/net/mlx4/alloc.o] Error 1
make[2]: *** [drivers/net/mlx4] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

I have tested the patch for the build failure.

Signed-off-by: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
--
--- linux-2.6.25-rc1/drivers/net/mlx4/alloc.c	2008-02-11 03:48:14.00000=
0000 +0530
+++ linux-2.6.25-rc1/drivers/net/mlx4/~alloc.c	2008-02-12 14:43:46.0000=
00000 +0530
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
 #include <linux/bitmap.h>
 #include <linux/dma-mapping.h>
+#include <linux/vmalloc.h>
=20
 #include "mlx4.h"
=20
--=20
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
