From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/3] vhost: logging fixes
Date: Tue, 23 Feb 2010 18:57:31 +0200
Message-ID: <cover.1266943453.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	gl
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches on top of net-next fix issues related to write
logging in vhost. This fixes all known to me logging issues, migration
now works for me while under stress in both TX and RX directions.
Rusty's going on vacation, I am guessing he won't have time to review
this: Gleb, Juan, Herbert, could one of you review this patchset please?

There's also the send queue full issue reported by
Sridhar Samudrala which I'm testing various fixes for,
that patch is contained to vhost/net though,
so there's no conflict, patch will be posted separately.


Michael S. Tsirkin (3):
  vhost: logging thinko fix
  vhost: initialize log eventfd context pointer
  vhost: fix get_user_pages_fast error handling

 drivers/vhost/vhost.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)
