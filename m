From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL net-next] vhost enhancements for 3.16
Date: Mon, 2 Jun 2014 23:55:15 +0300
Message-ID: <20140602205515.GA10287@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mimu@linux.vnet.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, romain@orebokech.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, arei.gonglei@huawei.com
To: David Miller <davem@davemloft.net>
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

The following changes since commit 96b2e73c5471542cb9c622c4360716684f8797ed:

  Revert "net/mlx4_en: Use affinity hint" (2014-06-02 00:18:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-next

for you to fetch changes up to 2ae76693b8bcabf370b981cd00c36cd41d33fabc:

  vhost: replace rcu with mutex (2014-06-02 23:47:59 +0300)

----------------------------------------------------------------
Michael S. Tsirkin (2):
      vhost-net: extend device allocation to vmalloc
      vhost: replace rcu with mutex

 drivers/vhost/net.c   | 23 ++++++++++++++++++-----
 drivers/vhost/vhost.c | 10 +++++++++-
 2 files changed, 27 insertions(+), 6 deletions(-)
