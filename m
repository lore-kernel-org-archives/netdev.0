From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [git pull] sock_recvmsg() redundant argument
Date: Sat, 9 Apr 2016 21:07:05 +0100
Message-ID: <20160409200704.GE25498@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38654 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424AbcDIUHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 16:07:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preparation for a bunch of iov_iter stuff; I'm not sure if all of those should
go via net-next (e.g. cifs stuff almost certainly doesn't, etc.), but this
bit is common to all those series and it would be better off in your tree.
sendmsg counterpart was "get rid of the size argument of sock_sendmsg()" and
it went in more than a year ago; this one sat in my private queue since
then.

The following changes since commit f55532a0c0b8bb6148f4e07853b876ef73bc69ca:

  Linux 4.6-rc1 (2016-03-26 16:03:24 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git for-davem

for you to fetch changes up to 2da62906b1e298695e1bb725927041cd59942c98:

  [net] drop 'size' argument of sock_recvmsg() (2016-03-28 13:57:51 -0400)

----------------------------------------------------------------
Al Viro (1):
      [net] drop 'size' argument of sock_recvmsg()

 drivers/target/iscsi/iscsi_target_util.c |  5 ++---
 include/linux/net.h                      |  3 +--
 net/socket.c                             | 23 ++++++++++-------------
 3 files changed, 13 insertions(+), 18 deletions(-)
