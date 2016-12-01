From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Thu, 1 Dec 2016 14:46:41 +1100
Message-ID: <20161201144641.7e6d73e4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Edward Cree <ecree@solarflare.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the tip tree got a conflict in:

  drivers/net/ethernet/sfc/Kconfig

between commit:

  5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")

from the net-next tree and commit:

  d1cbfd771ce8 ("ptp_clock: Allow for it to be optional")

from the tip tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/sfc/Kconfig
index 0e16197e4f18,83f4766a1da0..000000000000
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@@ -5,11 -5,11 +5,11 @@@ config SF
  	select CRC32
  	select I2C
  	select I2C_ALGOBIT
- 	select PTP_1588_CLOCK
 +	select SFC_FALCON
+ 	imply PTP_1588_CLOCK
  	---help---
  	  This driver supports 10/40-gigabit Ethernet cards based on
 -	  the Solarflare SFC4000, SFC9000-family and SFC9100-family
 -	  controllers.
 +	  the Solarflare SFC9000-family and SFC9100-family controllers.
  
  	  To compile this driver as a module, choose M here.  The module
  	  will be called sfc.
