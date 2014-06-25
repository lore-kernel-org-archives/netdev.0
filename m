From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Wed, 25 Jun 2014 14:05:39 +0300
Message-ID: <20140625110539.GA7386@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	romain@orebokech.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
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

The following changes since commit a497c3ba1d97fc69c1e78e7b96435ba8c2cb42ee:

  Linux 3.16-rc2 (2014-06-21 19:02:54 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 68404441557d8db5ac853379a4fb9c1adedea4fd:

  vhost-scsi: don't open-code kvfree (2014-06-23 09:22:48 +0300)

----------------------------------------------------------------
vhost: infrastructure fixes for 3.16

Two cleanup patches removing code duplication that got introduced by changes in
rc1.  Not fixing crashes, but I'd rather not carry the duplicate code until the
next merge window.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Michael S. Tsirkin (1):
      vhost-scsi: don't open-code kvfree

Romain Francoise (1):
      vhost-net: don't open-code kvfree

 drivers/vhost/net.c  | 12 ++----------
 drivers/vhost/scsi.c | 12 ++----------
 2 files changed, 4 insertions(+), 20 deletions(-)
