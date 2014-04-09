From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net, V1 0/3] Fix issues with Heper-V network offload code
Date: Wed,  9 Apr 2014 15:00:10 -0700
Message-ID: <1397080810-17953-1-git-send-email-kys@microsoft.com>
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

WS2008 R2 does not support udp checksum offload. Furthermore, ws2012 and
ws2012 r2 have issues offloading udp checksum from Linux guests.
This patch-set addresses these issues as well as other bug fixes.
Please apply.

In this version, I have addressed the comment from David Miller with reagards
to COWing the skb prior to modifying the header (patch 3/3).

K. Y. Srinivasan (3):
  Drivers: net: hyperv: Allocate memory for all possible per-pecket
    information
  Drivers: net: hyperv: Negotiate suitable ndis version for offload
    support
  Drivers: net: hyperv: Address UDP checksum issues

 drivers/net/hyperv/hyperv_net.h   |    1 +
 drivers/net/hyperv/netvsc.c       |    2 +-
 drivers/net/hyperv/netvsc_drv.c   |   23 +++++++++++++++++++++--
 drivers/net/hyperv/rndis_filter.c |   12 +++++++++++-
 4 files changed, 34 insertions(+), 4 deletions(-)

-- 
1.7.4.1
