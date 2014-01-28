From: David Howells <dhowells@redhat.com>
Subject: [GIT PULL] AF_RXRPC fixes
Date: Tue, 28 Jan 2014 17:07:36 +0000
Message-ID: <8672.1390928856@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	Tim Smith <tim@electronghost.co.uk>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are some small AF_RXRPC fixes.

 (1) Fix a place where a spinlock is taken conditionally but is released
     unconditionally.

 (2) Fix a double-free that happens when cleaning up on a checksum error.

 (3) Fix handling of CHECKSUM_PARTIAL whilst delivering messages to userspace.

David
---
The following changes since commit d8ec26d7f8287f5788a494f56e8814210f0e64be:

  Linux 3.13 (2014-01-19 18:40:07 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/rxrpc-20140126

for you to fetch changes up to 1ea427359dde1573815e19c411ce08fdf0c42cfe:

  af_rxrpc: Handle frames delivered from another VM (2014-01-26 11:45:04 +0000)

----------------------------------------------------------------
RxRPC fixes

----------------------------------------------------------------
Alexey Khoroshilov (1):
      RxRPC: do not unlock unheld spinlock in rxrpc_connect_exclusive()

Tim Smith (2):
      af_rxrpc: Avoid setting up double-free on checksum error
      af_rxrpc: Handle frames delivered from another VM

 net/rxrpc/ar-connection.c | 2 ++
 net/rxrpc/ar-recvmsg.c    | 7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)
