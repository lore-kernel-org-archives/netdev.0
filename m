From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V2 0/2] ethernet: intel: Support Hyper-V hosts
Date: Sun, 17 Apr 2016 22:22:47 -0700
Message-ID: <1460956969-17601-1-git-send-email-kys@microsoft.com>
References: <1460956943-17560-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, eli@mellanox.com, jackm@mellanox.com,
 yevgenyp@mellanox.com, john.ronciak@intel.com,
 intel-wired-lan@lists.osuosl.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460956943-17560-1-git-send-email-kys@microsoft.com>
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
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   16 ++-
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  201 +++++++++++++++++++++
 5 files changed, 242 insertions(+), 4 deletions(-)

-- 
1.7.4.1
