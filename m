From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v2 net-next 0/2] hv_netvsc: sub channel initialization fixes
Date: Wed,  6 Sep 2017 13:53:04 -0700
Message-ID: <20170906205306.10541-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
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

One serious deadlock, and one minor optimization.

Stephen Hemminger (2):
  hv_netvsc: fix deadlock on hotplug
  hv_netvsc: avoid unnecessary wakeups on subchannel creation

 drivers/net/hyperv/hyperv_net.h   |   3 +
 drivers/net/hyperv/netvsc.c       |   3 +
 drivers/net/hyperv/netvsc_drv.c   |  11 +---
 drivers/net/hyperv/rndis_filter.c | 126 ++++++++++++++++++++++++++------------
 4 files changed, 96 insertions(+), 47 deletions(-)

-- 
2.11.0
