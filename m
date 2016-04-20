From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V5 0/2] ethernet: intel: Support Hyper-V hosts
Date: Tue, 19 Apr 2016 19:17:35 -0700
Message-ID: <1461118655-28103-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, eli@mellanox.com, jackm@mellanox.com,
 yevgenyp@mellanox.com, john.ronciak@intel.com,
 intel-wired-lan@lists.osuosl.org, alexander.duyck@gmail.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Make adjustments to the Intel 10G VF driver to support
running on Hyper-V hosts.

K. Y. Srinivasan (2):
  ethernet: intel: Add the device ID's presented while running on
    Hyper-V
  intel: ixgbevf: Support Windows hosts (Hyper-V)

 drivers/net/ethernet/intel/ixgbevf/defines.h      |    5 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   12 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   31 +++-
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  216 +++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
 6 files changed, 271 insertions(+), 7 deletions(-)

-- 
1.7.4.1
