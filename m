From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the y2038 tree with the net-next tree
Date: Mon, 5 Sep 2016 18:08:45 +1000
Message-ID: <20160905180845.7f6f63b8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Howells <dhowells@redhat.com>,
        Tina Ruchandani <ruchandani.tina@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

Today's linux-next merge of the y2038 tree got a conflict in:

  fs/afs/main.c

between commit:

  e0661dfc5961 ("afs: Need linux/random.h")

from the net-next tree and commit:

  549eb7b22e24 ("AFS: Correctly use 64-bit time for UUID")

from the y2038 tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc fs/afs/main.c
index 0b187ef3b5b7,129ff432391c..000000000000
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@@ -14,7 -14,7 +14,8 @@@
  #include <linux/init.h>
  #include <linux/completion.h>
  #include <linux/sched.h>
 +#include <linux/random.h>
+ #include <linux/ktime.h>
  #include "internal.h"
  
  MODULE_DESCRIPTION("AFS Client File System");
