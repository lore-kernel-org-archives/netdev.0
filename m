From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [git pull] skb_copy_{,and_csum_}datagram_msg() fixes
Date: Sun, 2 Apr 2017 17:23:28 +0100
Message-ID: <20170402162328.GH29622@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:41082 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdDBQXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 12:23:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fixes rsync et.al. regression since 3.19...

The following changes since commit c02ed2e75ef4c74e41e421acb4ef1494671585e8:

  Linux 4.11-rc4 (2017-03-26 14:15:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem

for you to fetch changes up to 3278682123811dd8ef07de5eb701fc4548fcebf2:

  make skb_copy_datagram_msg() et.al. preserve ->msg_iter on error (2017-04-02 12:10:57 -0400)

----------------------------------------------------------------
Al Viro (2):
      [iov_iter] new privimitive: iov_iter_revert()
      make skb_copy_datagram_msg() et.al. preserve ->msg_iter on error

 include/linux/uio.h |  6 ++++-
 lib/iov_iter.c      | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/datagram.c | 23 +++++++++++--------
 3 files changed, 82 insertions(+), 10 deletions(-)
