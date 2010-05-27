From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-2.6] vhost-net: error handling fixes
Date: Thu, 27 May 2010 14:57:14 +0300
Message-ID: <20100527115714.GA7899@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	krkumar2@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754935Ab0E0MBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 08:01:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
The following tree includes fixes dealing with error handling
in vhost-net. It is on top of net-2.6.
Please merge it for 2.6.35.
Thanks!

The following changes since commit 8a74ad60a546b13bd1096b2a61a7a5c6fd9ae17c:

  net: fix lock_sock_bh/unlock_sock_bh (2010-05-27 00:30:53 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Krishna Kumar (1):
      vhost: Fix host panic if ioctl called with wrong index

Takuya Yoshikawa (3):
      vhost: fix to check the return value of copy_to/from_user() correctly
      vhost-net: fix to check the return value of copy_to/from_user() correctly
      vhost: fix the memory leak which will happen when memory_access_ok fails

 drivers/vhost/net.c   |   14 ++++++------
 drivers/vhost/vhost.c |   57 +++++++++++++++++++++++++++---------------------
 2 files changed, 39 insertions(+), 32 deletions(-)

-- 
MST
