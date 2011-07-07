From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 7 Jul 2011 15:28:57 +1000
Message-ID: <20110707152857.83d48e1d1c175f811b255952@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesper Juhl <jj@chaosbits.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c between commit
219eb47e6f35 ("net/staging: add needed interrupt.h and hardirq.h
includes") from the net tree and commit 41134db17a7d ("Remove unneeded
version.h includes from drivers/staging/rtl*/") from the staging tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
index 00ee02f,52a7386..0000000
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
@@@ -19,8 -19,6 +19,7 @@@
  #include <linux/random.h>
  #include <linux/delay.h>
  #include <linux/slab.h>
- #include <linux/version.h>
 +#include <linux/interrupt.h>
  #include <asm/uaccess.h>
  
  #include "dot11d.h"
