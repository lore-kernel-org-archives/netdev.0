From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/1] netvsc hot plug fix
Date: Wed,  6 Sep 2017 08:19:24 -0700
Message-ID: <20170906151925.15221-1-sthemmin@microsoft.com>
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

This is one fix for problems with hot add of network device
on Windows Server.

Stephen Hemminger (1):
  hv_netvsc: fix deadlock on hotplug

 drivers/net/hyperv/hyperv_net.h   |   1 +
 drivers/net/hyperv/netvsc_drv.c   |   8 +--
 drivers/net/hyperv/rndis_filter.c | 106 ++++++++++++++++++++++++++------------
 3 files changed, 74 insertions(+), 41 deletions(-)

-- 
2.11.0
