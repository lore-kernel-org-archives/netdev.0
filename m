From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: fix for 4.8
Date: Wed, 24 Aug 2016 06:35:35 +0300
Message-ID: <20160824063535-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	virtualization@lists.linux-foundation.org, bcodding@redhat.com
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

The following changes since commit fa8410b355251fd30341662a40ac6b22d3e38468:

  Linux 4.8-rc3 (2016-08-21 16:14:10 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to a77ec83a57890240c546df00ca5df1cdeedb1cc3:

  vhost/scsi: fix reuse of &vq->iov[out] in response (2016-08-23 17:16:57 +0300)

----------------------------------------------------------------
vhost: fix for 4.8

This includes a single bugfix for vhost-scsi.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Benjamin Coddington (1):
      vhost/scsi: fix reuse of &vq->iov[out] in response

 drivers/vhost/scsi.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
