From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: tcm_vhost fixes for 3.9
Date: Mon, 18 Mar 2013 13:20:03 +0200
Message-ID: <20130318112003.GA7809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	asias@redhat.com, mst@redhat.com, nab@linux-iscsi.org,
	target-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 8c6216d7f118a128678270824b6a1286a63863ca:

  Revert "ip_gre: make ipgre_tunnel_xmit() not parse network header as IP unconditionally" (2013-03-16 23:00:41 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

for you to fetch changes up to deb7cb067dabd3be625eaf5495da8bdc97377fc1:

  tcm_vhost: Flush vhost_work in vhost_scsi_flush() (2013-03-17 13:04:14 +0200)

----------------------------------------------------------------
Asias He (2):
      tcm_vhost: Add missed lock in vhost_scsi_clear_endpoint()
      tcm_vhost: Flush vhost_work in vhost_scsi_flush()

 drivers/vhost/tcm_vhost.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)
