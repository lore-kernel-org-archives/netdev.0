From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 0/2] Part 3: handle random addresses on blackfin
Date: Thu, 16 Feb 2012 18:09:29 +0100
Message-ID: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Bob Liu <bob.liu@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Scott Jiang <scott.jiang@analog.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Steven Miao <realmz6@gmail.com>,
	uclinux-dist-devel@blackfin.uclinux.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The third part of my patch series to fix the handling of 
addr_assign_type for random MAC addresses. This contains the 
changes for the blackfin architecture and the adi ethernet
driver.

Please make sure you do a short compile test before pushing them.

Thanks!

Danny Kukawka (2):
  arch/blackfin: don't generate random mac in bfin_get_ether_addr()
  adi: adapt to eth_hw_addr_random() and changes in arch/blackfin

 arch/blackfin/mach-bf518/boards/ezbrd.c      |    3 ++-
 arch/blackfin/mach-bf518/boards/tcm-bf518.c  |    5 ++---
 arch/blackfin/mach-bf527/boards/ad7160eval.c |    3 ++-
 arch/blackfin/mach-bf527/boards/cm_bf527.c   |    5 ++---
 arch/blackfin/mach-bf527/boards/ezbrd.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/ezkit.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/tll6527m.c   |    3 ++-
 arch/blackfin/mach-bf537/boards/cm_bf537e.c  |    5 ++---
 arch/blackfin/mach-bf537/boards/cm_bf537u.c  |    5 ++---
 arch/blackfin/mach-bf537/boards/dnp5370.c    |    3 ++-
 arch/blackfin/mach-bf537/boards/pnav10.c     |    5 ++---
 arch/blackfin/mach-bf537/boards/stamp.c      |    3 ++-
 arch/blackfin/mach-bf537/boards/tcm_bf537.c  |    5 ++---
 drivers/net/ethernet/adi/bfin_mac.c          |   15 +++++++++------
 drivers/net/ethernet/adi/bfin_mac.h          |    2 +-
 15 files changed, 36 insertions(+), 32 deletions(-)

-- 
1.7.8.3
