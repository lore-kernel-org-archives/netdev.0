From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL] first round of vhost-net enhancements for net-next
Date: Tue, 4 May 2010 00:32:45 +0300
Message-ID: <20100503213244.GA16006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
The following tree includes a couple of enhancements that help vhost-net.
Please pull them for net-next. Another set of patches is under
debugging/testing and I hope to get them ready in time for 2.6.35,
so there may be another pull request later.

Thanks!

The following changes since commit 7ef527377b88ff05fb122a47619ea506c631c914:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6 (2010-05-02 22:02:06 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost

Michael S. Tsirkin (2):
      tun: add ioctl to modify vnet header size
      macvtap: add ioctl to modify vnet header size

 drivers/net/macvtap.c  |   31 +++++++++++++++++++++++++++----
 drivers/net/tun.c      |   32 ++++++++++++++++++++++++++++----
 include/linux/if_tun.h |    2 ++
 3 files changed, 57 insertions(+), 8 deletions(-)

-- 
MST
