From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/3] virtio_net: spelling fixes
Date: Mon, 9 Dec 2013 16:18:45 -0800
Message-ID: <20131209161845.218642f7@nehalam.linuxnetplumber.net>
References: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/virtio_net.c	2013-12-09 16:12:41.409051865 -0800
+++ b/drivers/net/virtio_net.c	2013-12-09 16:12:43.872996856 -0800
@@ -873,7 +873,7 @@ static netdev_tx_t start_xmit(struct sk_
 /*
  * Send command via the control virtqueue and check status.  Commands
  * supported by the hypervisor, as indicated by feature bits, should
- * never fail unless improperly formated.
+ * never fail unless improperly formatted.
  */
 static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 				 struct scatterlist *out)
@@ -1061,7 +1061,7 @@ static void virtnet_set_rx_mode(struct n
 	void *buf;
 	int i;
 
-	/* We can't dynamicaly set ndo_set_rx_mode, so return gracefully */
+	/* We can't dynamically set ndo_set_rx_mode, so return gracefully */
 	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
 		return;
