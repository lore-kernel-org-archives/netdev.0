From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Fri, 3 Feb 2017 23:43:09 +0200
Message-ID: <20170203234309-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: miket@us.ibm.com, kvm@vger.kernel.org, mst@redhat.com, marc.zyngier@arm.com,
	netdev@vger.kernel.org, will.deacon@arm.com, dgilbert@redhat.com,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	amit.shah@redhat.com, virtualization@lists.linux-foundation.org,
	robin.murphy@arm.com
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

The following changes since commit 566cf877a1fcb6d6dc0126b076aad062054c2637:

  Linux 4.10-rc6 (2017-01-29 14:25:17 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 79134d11d030b886106bf45a5638c1ccb1f0856c:

  MAINTAINERS: update email address for Amit Shah (2017-02-03 23:40:36 +0200)

----------------------------------------------------------------
virtio, vhost: last minute fixes

ARM DMA fix revert
vhost endian-ness fix
MAINTAINERS: email address change for Amit

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Amit Shah (1):
      MAINTAINERS: update email address for Amit Shah

Halil Pasic (1):
      vhost: fix initialization for vq->is_le

Michael S. Tsirkin (1):
      Revert "vring: Force use of DMA API for ARM-based systems with legacy devices"

 MAINTAINERS                  |  2 +-
 drivers/vhost/vhost.c        | 10 ++++------
 drivers/virtio/virtio_ring.c |  7 -------
 3 files changed, 5 insertions(+), 14 deletions(-)
