From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 29 Jul 2010 11:19:04 +1000
Message-ID: <20100729111904.90b148a6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/e1000e/hw.h between commit
ff847ac2d3e90edd94674c28bade25ae1e6a2e49 ("") from the net-current tree
and commit d3738bb8203acf8552c3ec8b3447133fc0938ddd ("e1000e: initial
support for 82579 LOMs") from the net tree.

Just context changes. I fixed it up (see below) and can carry the fix for
a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/e1000e/hw.h
index 664ed58,0cd569a..0000000
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@@ -308,8 -312,8 +312,8 @@@ enum e1e_registers 
  #define E1000_KMRNCTRLSTA_INBAND_PARAM	0x9    /* Kumeran InBand Parameters */
  #define E1000_KMRNCTRLSTA_DIAG_NELPBK	0x1000 /* Nearend Loopback mode */
  #define E1000_KMRNCTRLSTA_K1_CONFIG	0x7
 -#define E1000_KMRNCTRLSTA_K1_ENABLE	0x140E
 +#define E1000_KMRNCTRLSTA_K1_ENABLE	0x0002
- #define E1000_KMRNCTRLSTA_K1_DISABLE	0x1400
+ #define E1000_KMRNCTRLSTA_HD_CTRL	0x0002
  
  #define IFE_PHY_EXTENDED_STATUS_CONTROL	0x10
  #define IFE_PHY_SPECIAL_CONTROL		0x11 /* 100BaseTx PHY Special Control */
