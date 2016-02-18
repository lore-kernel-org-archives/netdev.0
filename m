From: Robert Richter <rrichter@caviumnetworks.com>
Subject: [PATCH 2/2] net, thunderx: Use bool in structs where possible
Date: Thu, 18 Feb 2016 13:39:09 +0100
Message-ID: <1455799149-19590-3-git-send-email-rrichter@caviumnetworks.com>
References: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rrichter@cavium.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S . Miller" <davem@davemloft.net>, Sunil Goutham
 <sgoutham@cavium.com>, Robert Richter <rric@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@cavium.com>

Looks like the :1 notation was accidentally introduced (this still
uses 1 byte per flag). Using bool instead, which is the common use.

Signed-off-by: Robert Richter <rrichter@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 688828865c48..fa5b1d2d8e23 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -262,9 +262,9 @@ struct nicvf {
 	struct pci_dev		*pdev;
 	u8			vf_id;
 	u8			node;
-	u8			tns_mode:1;
-	u8			sqs_mode:1;
-	u8			loopback_supported:1;
+	bool			tns_mode;
+	bool                    sqs_mode;
+	bool			loopback_supported;
 	bool			hw_tso;
 	u16			mtu;
 	struct queue_set	*qs;
@@ -353,9 +353,9 @@ struct nic_cfg_msg {
 	u8    msg;
 	u8    vf_id;
 	u8    node_id;
-	u8    tns_mode:1;
-	u8    sqs_mode:1;
-	u8    loopback_supported:1;
+	bool  tns_mode;
+	bool  sqs_mode;
+	bool  loopback_supported;
 	u8    mac_addr[ETH_ALEN];
 };
 
-- 
2.7.0.rc3
