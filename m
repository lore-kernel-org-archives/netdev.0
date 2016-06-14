From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: docs/tests
Date: Tue, 14 Jun 2016 23:17:03 +0300
Message-ID: <20160614231703-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	rppt@linux.vnet.ibm.com, geert@linux-m68k.org
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

The following changes since commit af8c34ce6ae32addda3788d54a7e340cad22516b:

  Linux 4.7-rc2 (2016-06-05 14:31:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 139ab4d4e68b8cf2a611b06c006a2195dc6bedf1:

  tools/virtio: add noring tool (2016-06-06 13:00:11 +0300)

----------------------------------------------------------------
virtio: docs, tests for 4.7

This merely has some documentation and a new test, seems safe to merge.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Geert Uytterhoeven (1):
      MAINTAINERS: Add file patterns for virtio device tree bindings

Michael S. Tsirkin (1):
      tools/virtio: add noring tool

Mike Rapoport (2):
      tools/virtio/ringtest: add usage example to README
      tools/virtio/ringtest: fix run-on-all.sh to work without /dev/cpu

 tools/virtio/ringtest/noring.c      | 69 +++++++++++++++++++++++++++++++++++++
 MAINTAINERS                         |  1 +
 tools/virtio/ringtest/Makefile      |  4 ++-
 tools/virtio/ringtest/README        |  4 +++
 tools/virtio/ringtest/run-on-all.sh |  4 +--
 5 files changed, 79 insertions(+), 3 deletions(-)
 create mode 100644 tools/virtio/ringtest/noring.c
