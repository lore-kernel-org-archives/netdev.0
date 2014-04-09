From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net,
 V1 2/3] Drivers: net: hyperv: Negotiate suitable ndis version for
 offload support
Date: Wed,  9 Apr 2014 15:00:46 -0700
Message-ID: <1397080847-17994-2-git-send-email-kys@microsoft.com>
References: <1397080810-17953-1-git-send-email-kys@microsoft.com>
 <1397080847-17994-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1397080847-17994-1-git-send-email-kys@microsoft.com>
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

Ws2008R2 supports ndis_version 6.1 and 6.1 is the minimal version required
for various offloads. Negotiate ndis_version 6.1 when on ws2008r2.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index daddea2..f7629ec 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -344,7 +344,7 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 
 	if (net_device->nvsp_version <= NVSP_PROTOCOL_VERSION_4)
-		ndis_version = 0x00050001;
+		ndis_version = 0x00060001;
 	else
 		ndis_version = 0x0006001e;
 
-- 
1.7.4.1
