From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/7] drivers/net: Remove pointer
	casts to same type
Date: Mon, 24 Mar 2014 13:15:33 -0700
Message-ID: <cover.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, nios2-dev@lists.rocketboards.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

All of these are pointless...

Joe Perches (7):
  altera: Remove casts of pointer to same type
  alx: Remove casts of pointer to same type
  intel: Remove casts of pointer to same type
  qlcnic: Remove casts of pointer to same type
  carl9170: Remove casts of pointer to same type
  mwifiex: Remove casts of pointer to same type
  rtlwifi: Remove casts of pointer to same type

 drivers/net/ethernet/altera/altera_tse_main.c      |  4 +-
 drivers/net/ethernet/atheros/alx/main.c            |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  2 +-
 drivers/net/wireless/ath/carl9170/rx.c             |  2 +-
 drivers/net/wireless/mwifiex/pcie.c                |  6 +--
 drivers/net/wireless/mwifiex/scan.c                |  2 +-
 drivers/net/wireless/mwifiex/tdls.c                |  6 +--
 drivers/net/wireless/rtlwifi/core.c                |  2 +-
 drivers/net/wireless/rtlwifi/ps.c                  | 19 ++++---
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |  5 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  4 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 57 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        | 14 ++---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        | 14 +++--
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  5 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 60 ++++++++++------------
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  4 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |  2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 57 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  4 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |  4 +-
 23 files changed, 132 insertions(+), 151 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
