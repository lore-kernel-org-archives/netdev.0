From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: fixes
Date: Tue, 28 Mar 2017 21:32:50 +0300
Message-ID: <20170328213250-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux@leemhuis.info,
	labbott@redhat.com
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

The following changes since commit c02ed2e75ef4c74e41e421acb4ef1494671585e8:

  Linux 4.11-rc4 (2017-03-26 14:15:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to f0bb2d50dfcc519f06f901aac88502be6ff1df2c:

  virtio_balloon: prevent uninitialized variable use (2017-03-28 20:41:28 +0300)

----------------------------------------------------------------
virtio: fixes

Fixes to multiple issues in virtio. Most notably
a regression fix for crashes reported by Fedora users.
Hybernate is still reportedly broken, working on it.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Arnd Bergmann (1):
      virtio_balloon: prevent uninitialized variable use

Jason Wang (1):
      virtio_pci: fix out of bound access for msix_names

Ladi Prosek (2):
      virtio_balloon: init 1st buffer in stats vq
      virtio-balloon: use actual number of stats for stats queue buffers

 drivers/virtio/virtio_balloon.c    | 19 +++++++++++++------
 drivers/virtio/virtio_pci_common.c |  9 +++++----
 2 files changed, 18 insertions(+), 10 deletions(-)
