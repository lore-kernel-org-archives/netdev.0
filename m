From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost-net: 2.6.38 - warning fix
Date: Tue, 1 Feb 2011 17:44:40 +0200
Message-ID: <20110201154440.GA22819@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please merge for 2.6.38. Not the most elegant fix,
but it does fix the noise in dmesg that interferes with
kvm debugging, and probably the best we can do for 2.6.38.

The following changes since commit fca540ab5f4718c6133f71f7be1793066008bf89:

  enc28j60: Fix reading of transmit status vector (2011-01-31 20:56:54 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (1):
      vhost: rcu annotation fixup

 drivers/vhost/net.c   |    9 +++++----
 drivers/vhost/vhost.h |    6 +++---
 2 files changed, 8 insertions(+), 7 deletions(-)
