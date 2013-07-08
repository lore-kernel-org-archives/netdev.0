From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Mon, 8 Jul 2013 14:45:56 +0300
Message-ID: <20130708114556.GA17036@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
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

The following changes since commit 8bb495e3f02401ee6f76d1b1d77f3ac9f079e376:

  Linux 3.10 (2013-06-30 15:13:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 09a34c8404c1d4c5782de319c02e1d742c57875c:

  vhost/test: update test after vhost cleanups (2013-07-07 18:02:25 +0300)

----------------------------------------------------------------
vhost: fixes and cleanups 3.11

This includes some fixes and cleanups for vhost net and scsi drivers.
The scsi driver changes will cause a conflict with  Nicholas Bellinger's scsi
target changes, but the conflicting commit in my tree simply renames some
variables so it's trivial to resolve.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Asias He (8):
      vhost: Simplify dev->vqs[i] access
      vhost-scsi: Remove unnecessary forward struct vhost_scsi declaration
      vhost-scsi: Rename struct vhost_scsi *s to *vs
      vhost-scsi: Make func indention more consistent
      vhost-scsi: Rename struct tcm_vhost_tpg *tv_tpg to *tpg
      vhost-scsi: Rename struct tcm_vhost_cmd *tv_cmd to *cmd
      vhost: Make vhost a separate module
      vhost: Make local function static

Michael S. Tsirkin (2):
      vhost-net: fix use-after-free in vhost_net_flush
      vhost/test: update test after vhost cleanups

 drivers/vhost/Kconfig  |   8 +
 drivers/vhost/Makefile |   3 +-
 drivers/vhost/net.c    |  13 +-
 drivers/vhost/scsi.c   | 472 ++++++++++++++++++++++++++-----------------------
 drivers/vhost/test.c   |  33 ++--
 drivers/vhost/vhost.c  |  86 +++++++--
 drivers/vhost/vhost.h  |   2 +
 7 files changed, 356 insertions(+), 261 deletions(-)
