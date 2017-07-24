From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/6] netvsc: minor fixes
Date: Mon, 24 Jul 2017 10:57:24 -0700
Message-ID: <20170724175730.31806-1-sthemmin@microsoft.com>
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

This fixes fallout from previous patch related to RTNL and RCU
annotaiton. Also one patch sent to wrong list.

Mohammed Gamal (1):
  netvsc: Remove redundant use of ipv6_hdr()

Stephen Hemminger (5):
  netvsc: remove bogus rtnl_unlock
  netvsc: prefetch the first incoming ring element
  netvsc: fix netvsc_set_channels
  netvsc: include rtnetlink.h
  netvsc: remove no longer used max_num_rss queues

 drivers/net/hyperv/hyperv_net.h   |  1 -
 drivers/net/hyperv/netvsc.c       |  8 +++++-
 drivers/net/hyperv/netvsc_drv.c   | 54 +++++++++++++++------------------------
 drivers/net/hyperv/rndis_filter.c |  1 +
 4 files changed, 28 insertions(+), 36 deletions(-)

-- 
2.11.0
