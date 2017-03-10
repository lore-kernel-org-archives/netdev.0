From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH v2 net 0/8] net: bcmgenet: minor bug fixes
Date: Thu,  9 Mar 2017 16:58:42 -0800
Message-ID: <20170310005850.10808-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2: Accidentally sent the wrong set after rebasing.

This collection contains a number of fixes for minor issues with the
bcmgenet driver most of which were present in the initial submission
of the driver.

Some bugs were uncovered by inspection prior to the upcoming update for
GENETv5 support:
  net: bcmgenet: correct the RBUF_OVFL_CNT and RBUF_ERR_CNT MIB values
  net: bcmgenet: correct MIB access of UniMAC RUNT counters
  net: bcmgenet: reserved phy revisions must be checked first
  net: bcmgenet: synchronize irq0 status between the isr and task

Others bugs were found in power management testing:
  net: bcmgenet: power down internal phy if open or resume fails
  net: bcmgenet: Power up the internal PHY before probing the MII
  net: bcmgenet: decouple flow control from bcmgenet_tx_reclaim
  net: bcmgenet: add begin/complete ethtool ops

Doug Berger (7):
  net: bcmgenet: correct the RBUF_OVFL_CNT and RBUF_ERR_CNT MIB values
  net: bcmgenet: correct MIB access of UniMAC RUNT counters
  net: bcmgenet: reserved phy revisions must be checked first
  net: bcmgenet: power down internal phy if open or resume fails
  net: bcmgenet: synchronize irq0 status between the isr and task
  net: bcmgenet: Power up the internal PHY before probing the MII
  net: bcmgenet: decouple flow control from bcmgenet_tx_reclaim

Edwin Chan (1):
  net: bcmgenet: add begin/complete ethtool ops

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 206 ++++++++++++++++++-------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  16 +-
 2 files changed, 158 insertions(+), 64 deletions(-)

-- 
2.11.1
