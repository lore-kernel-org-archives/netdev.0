From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] virtio: last minute fixes for 3.4
Date: Thu, 17 May 2012 12:35:39 +0300
Message-ID: <20120517093539.GA30280@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, uobergfe@redhat.com,
	amit.shah@redhat.com, David Miller <davem@davemloft.net>
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

The following changes since commit 0e93b4b304ae052ba1bc73f6d34a68556fe93429:

  Merge git://git.kernel.org/pub/scm/virt/kvm/kvm (2012-05-16 14:30:51 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git for_linus

for you to fetch changes up to ec13ee80145ccb95b00e6e610044bbd94a170051:

  virtio_net: invoke softirqs after __napi_schedule (2012-05-17 12:16:38 +0300)

----------------------------------------------------------------
virtio: last minute fixes for 3.4

Here are a couple of last minute virtio fixes for 3.4.
Hope it's not too late yes - I might have tried too hard
to make sure the fix is well tested.

Fixes are by Amit and myself. One fixes module removal
and one suspend of a VM, the last one the handling of out
of memory condition.
They are thus very low risk as most people never hit these paths, but do fix
very annoying problems for people that do use the feature.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Amit Shah (2):
      virtio: console: tell host of open ports after resume from s3/s4
      virtio: balloon: let host know of updated balloon size before module removal

Michael S. Tsirkin (1):
      virtio_net: invoke softirqs after __napi_schedule

 drivers/char/virtio_console.c   |    7 +++++++
 drivers/net/virtio_net.c        |    2 ++
 drivers/virtio/virtio_balloon.c |    1 +
 3 files changed, 10 insertions(+), 0 deletions(-)
