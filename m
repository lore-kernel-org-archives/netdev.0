From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Fri, 9 Apr 2010 10:41:35 +1000
Message-ID: <20100409104135.d6008487.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	chavey <chavey@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/core/ethtool.c between commit
5a0e3ad6af8660be21ca98a971cd00f331318c05 ("include cleanup: Update gfp.h
and slab.h includes to prepare for breaking implicit slab.h inclusion
from percpu.h") from Linus' tree and commit
97f8aefbbfb5aa5c9944e5fa8149f1fdaf71c7b6 ("net: fix ethtool coding style
errors and warnings") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix
for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/ethtool.c
index 9d55c57,99e9f85..0000000
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@@ -18,8 -18,7 +18,8 @@@
  #include <linux/ethtool.h>
  #include <linux/netdevice.h>
  #include <linux/bitops.h>
+ #include <linux/uaccess.h>
 +#include <linux/slab.h>
- #include <asm/uaccess.h>
  
  /*
   * Some useful ethtool_ops methods that're device independent.
