From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V3 1/2 net-next] Drivers: hv: vmbus: Export the
 vmbus_sendpacket_pagebuffer_ctl()
Date: Tue, 17 Mar 2015 09:02:46 -0700
Message-ID: <1426608167-14180-1-git-send-email-kys@microsoft.com>
References: <1426608145-14139-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1426608145-14139-1-git-send-email-kys@microsoft.com>
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

Export the vmbus_sendpacket_pagebuffer_ctl() interface. This interface
will be used in the netvsc driver to optimize signalling the host.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/hv/channel.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index da53180..e58cdb7 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -710,6 +710,7 @@ int vmbus_sendpacket_pagebuffer_ctl(struct vmbus_channel *channel,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(vmbus_sendpacket_pagebuffer_ctl);
 
 /*
  * vmbus_sendpacket_pagebuffer - Send a range of single-page buffer
-- 
1.7.4.1
