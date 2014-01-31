From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/2] Drivers: net: hyperv: Cleanup the recive path
Date: Fri, 31 Jan 2014 08:24:38 -0800
Message-ID: <1391185478-5655-1-git-send-email-kys@microsoft.com>
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

Some minor cleanup of the receive path. Get rid of unnecessary
indirection as well as unnecessary re-establishment of state.

K. Y. Srinivasan (2):
  Drivers: net: hyperv: Get rid of the rndis_filter_packet structure
  Drivers: net: hyperv: Cleanup the receive path

 drivers/net/hyperv/hyperv_net.h   |    6 -----
 drivers/net/hyperv/netvsc.c       |   29 +++++++++++--------------
 drivers/net/hyperv/netvsc_drv.c   |    2 +-
 drivers/net/hyperv/rndis_filter.c |   41 ++----------------------------------
 4 files changed, 17 insertions(+), 61 deletions(-)

-- 
1.7.4.1
