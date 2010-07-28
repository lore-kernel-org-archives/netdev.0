From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-next-2.6] vhost-net patchset for 2.6.36
Date: Wed, 28 Jul 2010 16:32:31 +0300
Message-ID: <20100728133231.GA1932@redhat.com>
References: <20100701164127.GA3199@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	krkumar2@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100701164127.GA3199@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
The following tree includes the current vhost-net patchset.
Please merge it for 2.6.36.
Thanks!

The following changes since commit 4cfa580e7eebb8694b875d2caff3b989ada2efac:

  r6040: Fix args to phy_mii_ioctl(). (2010-07-21 21:10:49 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

David Stevens (1):
      vhost-net: mergeable buffers support

Michael S. Tsirkin (1):
      vhost: apply cgroup to vhost workers

Sridhar Samudrala (1):
      cgroups: Add an API to attach a task to current task's cgroup

Tejun Heo (1):
      vhost: replace vhost_workqueue with per-vhost kthread

 drivers/vhost/net.c    |  293 +++++++++++++++++++++++++++++++++++++++++-------
 drivers/vhost/vhost.c  |  228 ++++++++++++++++++++++++++++++++-----
 drivers/vhost/vhost.h  |   55 ++++++---
 include/linux/cgroup.h |    7 +
 kernel/cgroup.c        |   23 ++++
 5 files changed, 515 insertions(+), 91 deletions(-)

