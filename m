From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 0/8] vmxnet3 fixes and enhancements
Date: Fri, 14 Jan 2011 16:59:20 -0800
Message-ID: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series fixes bugs and enhances functionality in the
vmxnet3 driver.

---

Shreyas N Bhatewara (8):
      vmxnet3: fix ring size update
      vmxnet3: Preserve the MAC address configured by ifconfig
      vmxnet3: Enable HW Rx VLAN stripping by default
      vmxnet3: Provide required number of bytes in first SG buffer
      vmxnet3: Make ethtool handlers multiqueue aware
      vmxnet3: Disable napi in suspend, reenable in resume.
      vmxnet3: Add locking for access to command register
      vmxnet3: Dont allocate extra MSI-x vectors


 drivers/net/vmxnet3/vmxnet3_drv.c     |   93 +++++++----
 drivers/net/vmxnet3/vmxnet3_ethtool.c |  274 +++++++++++++++++++--------------
 drivers/net/vmxnet3/vmxnet3_int.h     |    7 -
 3 files changed, 226 insertions(+), 148 deletions(-)

-- 
Thanking you.
Shreyas
