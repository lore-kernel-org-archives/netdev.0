From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/6] Drivers: net: hyperv: Enable various offloads
Date: Thu,  6 Mar 2014 03:12:38 -0800
Message-ID: <1394104358-23438-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This patch set enables both checksum as well as segmentation offload.
As part of this effort I have enabled scatter gather I/O a well.

K. Y. Srinivasan (6):
  Drivers: net: hyperv: Enable scatter gather I/O
  Drivers: net: hyperv: Cleanup the send path
  Drivers: net: hyperv: Enable offloads on the host
  Drivers: net: hyperv: Enable receive side IP checksum offload
  Drivers: net: hyperv: Enable send side checksum offload
  Drivers: net: hyperv: Enable large send offload

 drivers/net/hyperv/hyperv_net.h   |  135 ++++++++++++++-
 drivers/net/hyperv/netvsc_drv.c   |  336 +++++++++++++++++++++++++++++++------
 drivers/net/hyperv/rndis_filter.c |  153 ++++++++++--------
 3 files changed, 501 insertions(+), 123 deletions(-)

-- 
1.7.4.1
