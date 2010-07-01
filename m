From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-2.6] vhost-net: more error handling fixes
Date: Thu, 1 Jul 2010 19:41:27 +0300
Message-ID: <20100701164127.GA3199@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	krkumar2@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
The following tree includes more fixes dealing with
error handling in vhost-net. It is on top of net-2.6.
Please merge it for 2.6.35.
Thanks!

The following changes since commit 38000a94a902e94ca8b5498f7871c6316de8957a:

  sky2: enable rx/tx in sky2_phy_reinit() (2010-06-23 14:37:04 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (2):
      vhost: break out of polling loop on error
      vhost: add unlikely annotations to error path

 drivers/vhost/net.c   |   12 ++++++-
 drivers/vhost/vhost.c |   86 +++++++++++++++++++++++++------------------------
 drivers/vhost/vhost.h |    8 ++--
 3 files changed, 58 insertions(+), 48 deletions(-)
-- 
MST
