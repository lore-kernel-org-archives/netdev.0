From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Mon, 15 Jul 2013 21:31:49 +0300
Message-ID: <20130715183149.GA8215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Linus Torvalds <torvalds@linux-foundation.org>
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

The following changes since commit 09a34c8404c1d4c5782de319c02e1d742c57875c:

  vhost/test: update test after vhost cleanups (2013-07-07 18:02:25 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 22fa90c7fb479694d6affebc049d21f06b714be6:

  vhost: Remove custom vhost rcu usage (2013-07-11 15:38:40 +0300)

----------------------------------------------------------------
vhost: more fixes for 3.11

This includes some fixes for vhost net and scsi drivers.
The test module has already been reworked to avoid rcu
usage, but the necessary core changes are missing,
we fixed this.
Unlikely to affect any real-world users, but it's
early in the cycle so, let's merge them.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Asias He (3):
      vhost-net: Always access vq->private_data under vq mutex
      vhost-scsi: Always access vq->private_data under vq mutex
      vhost: Remove custom vhost rcu usage

 drivers/vhost/net.c   | 37 ++++++++++++++++---------------------
 drivers/vhost/scsi.c  | 17 ++++++-----------
 drivers/vhost/test.c  |  6 ++----
 drivers/vhost/vhost.h | 10 ++--------
 4 files changed, 26 insertions(+), 44 deletions(-)
