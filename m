From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 00/11] remove open coded ns_to_timespec64 and reverse
Date: Tue, 31 Mar 2015 23:08:05 +0200
Message-ID: <cover.1427835485.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is a follow up to the recent timespec64 work for the
PTP Hardware Clock drivers.  Arnd noticed that drivers are using open
coded implementations of ns_to_timespec64 and timespec64_to_ns.  This
series replaces the open coded logic with the helper functions.

Thanks,
Richard

Richard Cochran (11):
  ptp: blackfin: use helpers for converting ns to timespec.
  ptp: bnx2x: use helpers for converting ns to timespec.
  ptp: tg3: use helpers for converting ns to timespec.
  ptp: fec: use helpers for converting ns to timespec.
  ptp: gianfar: use helpers for converting ns to timespec.
  ptp: e1000e: use helpers for converting ns to timespec.
  ptp: igb: use helpers for converting ns to timespec.
  ptp: ixgbe: use helpers for converting ns to timespec.
  ptp: mlx4: use helpers for converting ns to timespec.
  ptp: stmmac: use helpers for converting ns to timespec.
  ptp: cpts: use helpers for converting ns to timespec.

 drivers/net/ethernet/adi/bfin_mac.c              |    8 +++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    7 ++-----
 drivers/net/ethernet/broadcom/tg3.c              |    4 +---
 drivers/net/ethernet/freescale/fec_ptp.c         |    7 ++-----
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    8 +++-----
 drivers/net/ethernet/intel/e1000e/ptp.c          |    4 +---
 drivers/net/ethernet/intel/igb/igb_ptp.c         |    7 ++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |    7 ++-----
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |    4 +---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    4 +---
 drivers/net/ethernet/ti/cpts.c                   |    7 ++-----
 11 files changed, 20 insertions(+), 47 deletions(-)

-- 
1.7.10.4
