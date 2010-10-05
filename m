From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-next-2.6] vhost-net patchset for 2.6.37
Date: Tue, 5 Oct 2010 20:27:32 +0200
Message-ID: <20101005182732.GA25796@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like it was a quiet cycle for vhost-net:
probably because most of energy was spent on bugfixes
that went in for 2.6.36.
People are working on multiqueue, tracing but I'm not
sure it'll get done in time for 2.6.37 - so here's
a tree with a single patch that helps windows guests
which we definitely want in the next kernel.

Please merge for 2.6.37.
Thanks!

The following changes since commit a00eac0c459abecb539fb2a2abd3122dd7ca5d4a:

  ppp: Use a real SKB control block in fragmentation engine. (2010-10-05 01:36:52 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

Jason Wang (1):
      vhost: max s/g to match qemu

 drivers/vhost/net.c   |    2 +-
 drivers/vhost/vhost.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/vhost/vhost.h |   18 ++++++++----------
 3 files changed, 57 insertions(+), 12 deletions(-)
