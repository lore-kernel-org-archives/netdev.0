From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the moduleh tree with the net tree
Date: Wed, 28 Sep 2011 16:36:56 +1000
Message-ID: <20110928163656.4d0ec3d9d40471f4e051605f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christian Lamparter <chunkeey@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

Today's linux-next merge of the moduleh tree got a conflict in
drivers/net/wireless/p54/txrx.c between commit 1cda0fd60963 ("p54: Use
do_div for 64-bit division to fix 32-bit kernels") from the  tree and
commit 9ec3f961e31a ("drivers/net: Add export.h to files using
EXPORT_SYMBOL/THIS_MODULE") from the moduleh tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/p54/txrx.c
index 2b97a89,d5c12bc..0000000
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@@ -19,7 -19,7 +19,8 @@@
  #include <linux/init.h>
  #include <linux/firmware.h>
  #include <linux/etherdevice.h>
+ #include <linux/export.h>
 +#include <asm/div64.h>
  
  #include <net/mac80211.h>
  
