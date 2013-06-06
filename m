From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 06 Jun 2013 12:16:35 -0700 (PDT)
Message-ID: <20130606.121635.836050550847993594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a quick one commit pull request to cure the
regression introduced by the MSG_CMSG_COMPAT change.

Please pull, thanks a lot!

The following changes since commit 4d3797d7e1861ac1af150a6189315786c5e1c820:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-06-05 19:19:04 +0900)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to a7526eb5d06b0084ef12d7b168d008fcf516caab:

  net: Unbreak compat_sys_{send,recv}msg (2013-06-06 11:52:14 -0700)

----------------------------------------------------------------
Andy Lutomirski (1):
      net: Unbreak compat_sys_{send,recv}msg

 include/linux/socket.h |  3 +++
 net/compat.c           | 13 +++++++++++--
 net/socket.c           | 72 +++++++++++++++++++++++++++++++++---------------------------------------
 3 files changed, 47 insertions(+), 41 deletions(-)
