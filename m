From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: minor changes on top of 3.12-rc1
Date: Wed, 18 Sep 2013 12:49:44 +0300
Message-ID: <20130918094944.GA1053@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	alonid@stratoscale.com
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

The following changes since commit 272b98c6455f00884f0350f775c5342358ebb73f:

  Linux 3.12-rc1 (2013-09-16 16:17:51 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to d3d665a654a35c47463d2aa6353bac3ce293f4f5:

  vhost-scsi: whitespace tweak (2013-09-17 22:56:09 +0300)

----------------------------------------------------------------
vhost: minor changes on top of 3.12-rc1

This fixes module loading for vhost-scsi, and tweaks locking in vhost core
a bit. Both of these are not exactly release blockers but it's early
in the cycle so I think it's a good idea to apply them now.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (2):
      vhost/scsi: use vmalloc for order-10 allocation
      vhost-scsi: whitespace tweak

Qin Chuanyu (1):
      vhost: wake up worker outside spin_lock

 drivers/vhost/scsi.c  | 43 ++++++++++++++++++++++++++++---------------
 drivers/vhost/vhost.c |  4 +++-
 2 files changed, 31 insertions(+), 16 deletions(-)
