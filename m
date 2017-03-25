From: kys@exchange.microsoft.com
Subject: [PATCH net-next 2/2] netvsc: Properly initialize the return value
Date: Fri, 24 Mar 2017 20:54:37 -0700
Message-ID: <1490414077-12617-2-git-send-email-kys@exchange.microsoft.com>
References: <1490414048-12578-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1490414048-12578-1-git-send-email-kys@exchange.microsoft.com>
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

Initialize the return value correctly.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index eb7ae79..f830bbb 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -855,7 +855,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	struct hv_device *hdev = ndevctx->device_ctx;
 	struct netvsc_device_info device_info;
 	bool was_running;
-	int ret;
+	int ret = 0;
 
 	if (!nvdev || nvdev->destroy)
 		return -ENODEV;
-- 
1.7.1
