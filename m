From: Amos Kong <kongjianjun@gmail.com>
Subject: [PATCH v2] net: fix wrong length of mac address
Date: Fri, 18 Jan 2013 15:51:54 +0800
Message-ID: <1358495514-18047-1-git-send-email-kongjianjun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amos Kong <kongjianjun@gmail.com>,
 devel@linuxdriverproject.org
To: davem@davemloft.net, kys@microsoft.com, haiyangz@microsoft.com
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Typo, it should be ETH_ALEN.

Signed-off-by: Amos Kong <kongjianjun@gmail.com>
---
v2: update commitlog, fix cc list
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f825a62..8264f0e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -349,7 +349,7 @@ static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
 	struct net_device_context *ndevctx = netdev_priv(ndev);
 	struct hv_device *hdev =  ndevctx->device_ctx;
 	struct sockaddr *addr = p;
-	char save_adr[14];
+	char save_adr[ETH_ALEN];
 	unsigned char save_aatype;
 	int err;
 
-- 
1.7.11.7
