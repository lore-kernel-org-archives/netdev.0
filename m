From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/6] virtio_net: use common code for virtio_net_hdr and skb
	GSO conversion
Date: Wed,  8 Jun 2016 16:09:16 +0300
Message-ID: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
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

Hi,

This patches introduce virtio_net_hdr_{from,to}_skb functions for
conversion of GSO information between skb and virtio_net_hdr.

Mike Rapoport (6):
  virtio_net: add _UAPI prefix to virtio_net header guards
  virtio_net: introduce virtio_net_hdr_{from,to}_skb
  macvtap: use common code for virtio_net_hdr and skb GSO conversion
  tuntap: use common code for virtio_net_hdr and skb GSO conversion
  virtio_net: use common code for virtio_net_hdr and skb GSO conversion
  packet: use common code for virtio_net_hdr and skb GSO conversion

 drivers/net/macvtap.c           |  95 +++----------------------------------
 drivers/net/tun.c               |  97 +++++++++-----------------------------
 drivers/net/virtio_net.c        |  78 ++++---------------------------
 include/linux/virtio_net.h      | 101 ++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/virtio_net.h |   6 +--
 net/packet/af_packet.c          |  36 +-------------
 6 files changed, 143 insertions(+), 270 deletions(-)
 create mode 100644 include/linux/virtio_net.h

-- 
1.9.1
