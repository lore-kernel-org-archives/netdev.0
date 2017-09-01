From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 0/2] btqcomsmd: Allow specifying board mac address
Date: Fri,  1 Sep 2017 13:41:16 -0700
Message-ID: <20170901204118.17123-1-bjorn.andersson@linaro.org>
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        Loic Poulain <loic.poulain@linaro.org>
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The btqcomsmd hardware lacks persistent storage of its mac address, so this
needs to be configured during initialization. The second patch in this series
reads the mac address from DT and does this, allowing the boot loader to
populate this board specific information.

Loic Poulain (2):
  Bluetooth: make baswap src const
  Bluetooth: btqcomsmd: BD address setup

 drivers/bluetooth/btqcomsmd.c     | 28 ++++++++++++++++++++++++++++
 include/net/bluetooth/bluetooth.h |  2 +-
 net/bluetooth/lib.c               |  4 ++--
 3 files changed, 31 insertions(+), 3 deletions(-)

-- 
2.12.0
