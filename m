From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC V2 PATCH 3/5] tuntap: introduce
	multiqueue flags
Date: Sat, 17 Sep 2011 14:02:38 +0800
Message-ID: <20110917060238.32666.4273.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
References: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	mirq-linux@rere.qmqm.pl, joe@perches.com, shemminger@vyatta.com
To: krkumar2@in.ibm.com, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110917055639.32666.89940.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Add flags to be used by creating multiqueue tuntap device.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/if_tun.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 06b1829..c92a291 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -34,6 +34,7 @@
 #define TUN_ONE_QUEUE	0x0080
 #define TUN_PERSIST 	0x0100	
 #define TUN_VNET_HDR 	0x0200
+#define TUN_TAP_MQ      0x0400
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -61,6 +62,7 @@
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_VNET_HDR	0x4000
 #define IFF_TUN_EXCL	0x8000
+#define IFF_MULTI_QUEUE 0x0100
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
