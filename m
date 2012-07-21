From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost-net changes for net/3.6
Date: Sun, 22 Jul 2012 01:54:36 +0300
Message-ID: <20120721225436.GA23519@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: asias@redhat.com, mst@redhat.com, nab@linux-iscsi.org,
	nab@risingtidesystems.com, pbonzini@redhat.com, stefanha@gmail.com,
	stefanha@linux.vnet.ibm.com, wuzhy@cn.ibm.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,
Please merge the following patches into net tree for 3.6.
They are on top of the current net-next.
Thanks!


The following changes since commit 186e868786f97c8026f0a81400b451ace306b3a4:

  forcedeth: spin_unlock_irq in interrupt handler fix (2012-07-20 16:18:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

for you to fetch changes up to 163049aefdc04323a2d17ec9f2862027b43b0502:

  vhost: make vhost work queue visible (2012-07-22 01:22:23 +0300)

----------------------------------------------------------------
Stefan Hajnoczi (2):
      vhost: Separate vhost-net features from vhost features
      vhost: make vhost work queue visible

 drivers/vhost/net.c   | 4 ++--
 drivers/vhost/test.c  | 4 ++--
 drivers/vhost/vhost.c | 5 ++---
 drivers/vhost/vhost.h | 6 +++++-
 4 files changed, 11 insertions(+), 8 deletions(-)
