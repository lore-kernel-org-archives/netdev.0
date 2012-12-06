From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL net-next] vhost: changes for 3.8
Date: Thu, 6 Dec 2012 17:18:00 +0200
Message-ID: <20121206151800.GA3889@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dinggnu@gmail.com, mst@redhat.com, yongjun_wei@trendmicro.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit b93196dc5af7729ff7cc50d3d322ab1a364aa14f:

  net: fix some compiler warning in net/core/neighbour.c (2012-12-05 21:50:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

for you to fetch changes up to 405d55c99da7a3045275fdb1a30614293a53c6e7:

  tcm_vhost: remove unused variable in vhost_scsi_allocate_cmd() (2012-12-06 17:09:19 +0200)

----------------------------------------------------------------
Cong Ding (1):
      tools:virtio: fix compilation warning

Michael S. Tsirkin (4):
      vhost: avoid backend flush on vring ops
      vhost-net: flush outstanding DMAs on memory change
      vhost-net: skip head management if no outstanding
      vhost-net: enable zerocopy tx by default

Wei Yongjun (1):
      tcm_vhost: remove unused variable in vhost_scsi_allocate_cmd()

 drivers/vhost/net.c        | 51 ++++++++++++++++++++++++++++++----------------
 drivers/vhost/tcm_vhost.c  |  7 ++++---
 drivers/vhost/vhost.c      |  7 +++----
 drivers/vhost/vhost.h      |  3 ++-
 tools/virtio/virtio_test.c |  2 +-
 5 files changed, 44 insertions(+), 26 deletions(-)
