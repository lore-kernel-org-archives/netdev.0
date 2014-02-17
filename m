From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/3] Drivers: net: hyperv: Cleanup the hyper-V networking code
Date: Sun, 16 Feb 2014 16:38:03 -0800
Message-ID: <1392597483-13307-1-git-send-email-kys@microsoft.com>
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

Get rid of some unnecessary code and some general cleanup.

K. Y. Srinivasan (3):
  Drivers: net: hyperv: Get rid of the rndis_filter_packet structure
  Drivers: net: hyperv: Cleanup the receive path
  Drivers: net: hyperv: Cleanup the netvsc receive callback functio

 drivers/net/hyperv/hyperv_net.h   |    8 +---
 drivers/net/hyperv/netvsc.c       |   62 +++++++++++++-----------------------
 drivers/net/hyperv/netvsc_drv.c   |    2 +-
 drivers/net/hyperv/rndis_filter.c |   41 ++----------------------
 4 files changed, 29 insertions(+), 84 deletions(-)

-- 
1.7.4.1
