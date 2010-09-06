From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-2.6] vhost-net: 2.6.36 regression fixes
Date: Mon, 6 Sep 2010 14:36:06 +0300
Message-ID: <20100906113606.GA16143@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
The following tree includes more regression fixes for vhost-net
in 2.6.36.  It is on top of net-2.6.
Please merge it for 2.6.36.
Thanks!

The following changes since commit 0b5d404e349c0236b11466c0a4785520c0be6982:

  pkt_sched: Fix lockdep warning on est_tree_lock in gen_estimator (2010-09-02 13:22:11 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (3):
      cgroups: fix API thinko
      vhost: fix attach to cgroups regression
      vhost: error handling fix

 drivers/vhost/vhost.c  |   80 ++++++++++++++++++++++++++++++++++-------------
 include/linux/cgroup.h |   11 ++++++-
 kernel/cgroup.c        |    9 +++--
 3 files changed, 73 insertions(+), 27 deletions(-)
-- 
MST
