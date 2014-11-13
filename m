From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Thu, 13 Nov 2014 23:22:10 +0200
Message-ID: <20141113212210.GA15309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, tgraf@suug.ch
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

The following changes since commit 206c5f60a3d902bc4b56dab2de3e88de5eb06108:

  Linux 3.18-rc4 (2014-11-09 14:55:29 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 65eca3a20264a8999570c269406196bd1ae23be7:

  virtio_console: move early VQ enablement (2014-11-13 09:53:26 +0200)

It seems like a good idea to merge this bugfix now, as it's clearly
a regression and several people complained.

----------------------------------------------------------------
virtio: bugfix for 3.18

This fixes a crash in virtio console
multi-channel mode that got introduced in -rc1.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Cornelia Huck (1):
      virtio_console: move early VQ enablement

 drivers/char/virtio_console.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
