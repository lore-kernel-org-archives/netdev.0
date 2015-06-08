From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio: (yet another) last-minute fix for 4.1
Date: Mon, 8 Jun 2015 23:13:21 +0200
Message-ID: <20150608231321-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, jiang.liu@linux.intel.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

The following changes since commit 8a7b19d8b542b87bccc3eaaf81dcc90a5ca48aea:

  include/uapi/linux/virtio_balloon.h: include linux/virtio_types.h (2015-06-01 15:46:54 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 210d150e1f5da506875e376422ba31ead2d49621:

  virtio_pci: Clear stale cpumask when setting irq affinity (2015-06-04 14:47:49 +0200)

----------------------------------------------------------------
virtio: last-minute fix for 4.1

This fixes a minor issue affecting multiqueue virtio net
when user keeps changing the number of active queues
and CPUs are added and removed by hotplug.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Jiang Liu (1):
      virtio_pci: Clear stale cpumask when setting irq affinity

 drivers/virtio/virtio_pci_common.c | 1 +
 1 file changed, 1 insertion(+)
