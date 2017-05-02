From: Gabriele Paoloni <gabriele.paoloni@huawei.com>
Subject: [RFC PATCH 0/2] net: ixgbe: disable relaxed ordering at runtime
Date: Tue, 2 May 2017 10:59:24 +0100
Message-ID: <1493719166-9036-1-git-send-email-gabriele.paoloni@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, gabriele.paoloni@huawei.com, asit.k.mallick@intel.com,
 catalin.marinas@arm.com, will.deacon@arm.com, linuxarm@huawei.com,
 ashok.raj@intel.com, helgaas@kernel.org, ganeshgr@chelsio.com,
 dingtianhong@huawei.com, jeffrey.t.kirsher@intel.com, leedom@gmail.com,
 leedom@chelsio.com, patrick.j.cramer@intel.com, arjun@chelsio.com,
 werner@chelsio.com, linux-arm-kernel@lists.infradead.org, amira@mellanox.com,
 netdev@vger.kernel.org, David.Laight@aculab.com, robin.murphy@arm.com,
 davem@davemloft.net
To: <davem@davemloft.com>, <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: gabriele paoloni <gabriele.paoloni@huawei.com>

This patchset is based on Casey's patchset:
https://www.spinics.net/lists/arm-kernel/msg578927.html

It is a proposal to convert the ixgbe driver to disable RO at runtime
depending on the root port flags.

TODO: Casey's patchset above add quirks to disable RO only for Intel
E5-26xx and AMD ARM A1100, whereas currently the Intel ixgbe driver
disable RO by default. Therefore there may be some other host quirks
to be added in drivers/pci/quirks....

gabriele paoloni (2):
  net: revert commit 1a8b6d76dc5b
  net: ixgbe: disable RO depending on the root port flags

 arch/Kconfig                                    |  3 ---
 arch/sparc/Kconfig                              |  1 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 35 ++++++++++++++-----------
 3 files changed, 20 insertions(+), 19 deletions(-)

-- 
2.7.4
