From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: fix for 4.2
Date: Fri, 7 Aug 2015 08:28:18 +0300
Message-ID: <20150807082818-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jasowang@redhat.com, mst@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 74d33293e467df61de1b1d8b2fbe29e550dec33b:

  Linux 4.2-rc5 (2015-08-02 18:34:55 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to df4198b1e0c4a7d1adde1e5c2ceb67ac10b391bb:

  virtio-input: reset device and detach unused during remove (2015-08-06 10:40:35 +0300)

----------------------------------------------------------------
virtio: fix for 4.2

A last minute fix for the new virtio input driver. It seems pretty obvious, and
the problem it's fixing would be quite hard to debug.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Jason Wang (1):
      virtio-input: reset device and detach unused during remove

 drivers/virtio/virtio_input.c | 4 ++++
 1 file changed, 4 insertions(+)
