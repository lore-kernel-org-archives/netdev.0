From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/2 net-next] hyperv: Enable batched notification
Date: Tue, 10 Mar 2015 11:49:43 -0700
Message-ID: <1426013383-2853-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, gregkh@linuxfoundation.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de,
 apw@canonical.com, jasowang@redhat.com
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

Take into consideration the xmit_more flag in skb to decide if we should
notify the host as we place packets in VMBUS.

The VMBUS API that would give us this control is already in Greg's tree, in this
patch-set, that API is exported so it can be used in the netvsc driver.

K. Y. Srinivasan (2):
  Drivers: hv: vmbus: Export the vmbus_sendpacket_pagebuffer_ctl()
  hyperv: Support batched notification

 drivers/hv/channel.c              |    1 +
 drivers/net/hyperv/hyperv_net.h   |    2 +-
 drivers/net/hyperv/netvsc.c       |   14 +++++++++-----
 drivers/net/hyperv/netvsc_drv.c   |    3 ++-
 drivers/net/hyperv/rndis_filter.c |    2 +-
 5 files changed, 14 insertions(+), 8 deletions(-)

-- 
1.7.4.1
