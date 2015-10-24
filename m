From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 0/4] net: thunderx: Support pass-2 revision hardware.
Date: Fri, 23 Oct 2015 17:14:06 -0700
Message-ID: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

With the availability of a new revision of the ThunderX NIC hardware a
few changes to the driver are required.  With these, the driver works
on all currently available hardware revisions.

David Daney (1):
  net: thunderx: Rewrite silicon revision tests.

Sunil Goutham (2):
  net: thunderx: Remove PF soft reset.
  net: thunderx: Fix incorrect subsystem devid of VF on pass2 silicon

Thanneeru Srinivasulu (1):
  net: thunderx: Incorporate pass2 silicon CPI index configuration
    changes

 drivers/net/ethernet/cavium/thunder/nic_main.c   | 42 ++++++++++++++++--------
 drivers/net/ethernet/cavium/thunder/nic_reg.h    |  4 +++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |  2 +-
 3 files changed, 34 insertions(+), 14 deletions(-)

-- 
1.8.3.1
