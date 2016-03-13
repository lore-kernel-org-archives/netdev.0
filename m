From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH 0/5] net: macb: Checkpatch cleanups
Date: Sun, 13 Mar 2016 12:10:42 -0700
Message-ID: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I backed out the variable scope changes and made a separate
patch for the ether_addr_copy change.

Changes from v1:
* Backed out variable scope changes
* Separated out ether_addr_copy into it's own commit
* Fixed typo in comments as suggested by Joe

Cheers,

Moritz

Moritz Fischer (5):
  net: macb: Fix coding style error message
  net: macb: Fix coding style warnings
  net: macb: Address checkpatch 'check' suggestions
  net: macb: Use ether_addr_copy over memcpy
  net: macb: Fix simple typo.

 drivers/net/ethernet/cadence/macb.c | 153 +++++++++++++++++-------------------
 1 file changed, 70 insertions(+), 83 deletions(-)

-- 
2.4.3
