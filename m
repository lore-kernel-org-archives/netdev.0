From: Tuomas Tynkkynen <tuomas@tuxera.com>
Subject: [PATCH 0/2] 9p: Fixes for hard-to-hit bugs
Date: Wed, 6 Sep 2017 17:59:06 +0300
Message-ID: <20170906145908.8082-1-tuomas@tuxera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <v9fs-developer@lists.sourceforge.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>,
        Tuomas Tynkkynen <tuomas@tuxera.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mpynet.fi ([82.197.21.84]:11403 "EHLO mx1.mpynet.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932718AbdIFPKd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 11:10:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches fix two hard-to-hit (but really annoying) bugs in 9p.
The first one was posted earlier in February (with one R-b), the second
is a new one.

Both of these have had soaking in NixOS distribution kernels for
a couple of months with no ill effects.

Tuomas Tynkkynen (2):
  fs/9p: Compare qid.path in v9fs_test_inode
  net/9p: Switch to wait_event_killable()

 fs/9p/vfs_inode.c      |  3 +++
 fs/9p/vfs_inode_dotl.c |  3 +++
 net/9p/client.c        |  3 +--
 net/9p/trans_virtio.c  | 13 ++++++-------
 net/9p/trans_xen.c     |  4 ++--
 5 files changed, 15 insertions(+), 11 deletions(-)

-- 
2.13.0
