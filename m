From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the s390 tree
Date: Wed, 14 Sep 2011 12:50:08 +1000
Message-ID: <20110914125008.6c7e2bd132ad8f473e7524ce@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Oberparleiter <peter.oberparleiter@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	Einar Lueck <elelueck@de.ibm.com>,
	Jan Glauber <jang@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/s390/cio/qdio_main.c between commit 003184781fea ("[S390] s390:
fix mismatch in summation of I/O IRQ statistics") from the s390 tree and
commit 104ea556ee7f ("qdio: support asynchronous delivery of storage
blocks") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/s390/cio/qdio_main.c
index a122c1c,9a12228..0000000
--- a/drivers/s390/cio/qdio_main.c
+++ b/drivers/s390/cio/qdio_main.c
@@@ -14,6 -14,8 +14,7 @@@
  #include <linux/timer.h>
  #include <linux/delay.h>
  #include <linux/gfp.h>
+ #include <linux/io.h>
 -#include <linux/kernel_stat.h>
  #include <linux/atomic.h>
  #include <asm/debug.h>
  #include <asm/qdio.h>
