From: kys@exchange.microsoft.com
Subject: [PATCH 0/6] Drivers: hv: Miscellaneous fixes
Date: Sun, 30 Apr 2017 16:20:20 -0700
Message-ID: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
References: <kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <kys@exchange.microsoft.com>
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

From: K. Y. Srinivasan <kys@microsoft.com>

Miscellaneous fixes to vmbus and util drivers.

Alex Ng (1):
  Tools: hv: vss: Thaw the filesystem and continue if freeze call has
    timed out

K. Y. Srinivasan (3):
  Drivers: hv: vmbus: Fix error code returned by vmbus_post_msg()
  Drivers: hv: util: Make hv_poll_channel() a little more efficient
  Drivers: hv: vmbus: Fix rescind handling

Long Li (1):
  HV: properly delay KVP packets when negotiation is in progress

Vitaly Kuznetsov (1):
  tools: hv: properly handle long paths

 drivers/hv/channel.c      |    8 ++++-
 drivers/hv/channel_mgmt.c |   69 ++++++++++++++++++++++++++++++++++----------
 drivers/hv/connection.c   |    9 ++++--
 drivers/hv/hv_kvp.c       |   14 +++++----
 drivers/hv/hyperv_vmbus.h |   11 +++++++
 drivers/hv/vmbus_drv.c    |   29 ++++++++++++++++++-
 tools/hv/hv_kvp_daemon.c  |   44 ++++++++++++-----------------
 tools/hv/hv_vss_daemon.c  |    4 ++-
 8 files changed, 133 insertions(+), 55 deletions(-)
