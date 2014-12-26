From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 0/2] tun: support socket system calls
Date: Thu, 25 Dec 2014 22:50:22 -0800
Message-ID: <1419576624-8999-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is an underlying socket object in struct tun that isn't accessible,
so if you try to do a recvmmsg on a tun file descriptor you'll get an
error. This small patchset allows external file objects to claim socket
status and enables it for tun_files.

Alex Gartrell (2):
  socket: Allow external sockets to use socket syscalls
  tun: enable socket system calls

 drivers/net/tun.c  | 34 ++++++++++++++++++++++------------
 include/linux/fs.h |  2 +-
 net/socket.c       |  3 ++-
 3 files changed, 25 insertions(+), 14 deletions(-)

-- 
Alex Gartrell <agartrell@fb.com>
