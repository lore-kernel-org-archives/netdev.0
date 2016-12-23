From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 0/9] several fixups for virtio-net XDP
Date: Fri, 23 Dec 2016 22:37:23 +0800
Message-ID: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Merry Xmas and a Happy New year to all:

This series tries to fixes several issues for virtio-net XDP which
could be categorized into several parts:

- fix several issues during XDP linearizing
- allow csumed packet to work for XDP_PASS
- make EWMA rxbuf size estimation works for XDP
- forbid XDP when GUEST_UFO is support
- remove big packet XDP support
- add XDP support or small buffer

Please see individual patches for details.

Thanks

Jason Wang (9):
  virtio-net: remove the warning before XDP linearizing
  virtio-net: correctly xmit linearized page on XDP_TX
  virtio-net: fix page miscount during XDP linearizing
  virtio-net: correctly handle XDP_PASS for linearized packets
  virtio-net: unbreak csumed packets for XDP_PASS
  virtio-net: make rx buf size estimation works for XDP
  virtio-net: forbid XDP when VIRTIO_NET_F_GUEST_UFO is support
  virtio-net: remove big packet XDP codes
  virtio-net: XDP support for small buffers

 drivers/net/virtio_net.c | 172 ++++++++++++++++++++++++++++-------------------
 1 file changed, 102 insertions(+), 70 deletions(-)

-- 
2.7.4
