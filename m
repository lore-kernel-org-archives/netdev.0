From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL net (try 2)] vhost-net: zercopy mode fixes
Date: Fri, 22 Jul 2011 09:32:38 +0300
Message-ID: <20110722063238.GB9637@redhat.com>
References: <20110722060046.GA8876@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mashirle@us.ibm.com, xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110722060046.GA8876@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixing a corrupted pull request sent earlier.
Sorry about the noise!

The following includes vhost-net fixes - both in the
experimental zero copy mode.
Please pull for 3.1.
Thanks!

The following changes since commit fd99beb9375b44309d5ed9c2b62063e23151610b:

  Merge branch 'vhost-net-next' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost (2011-07-19 10:12:44 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next

Michael S. Tsirkin (1):
      vhost-net: update used ring on backend change

Shirley Ma (1):
      vhost: handle wrap around in # of bufs math

 drivers/vhost/net.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)
