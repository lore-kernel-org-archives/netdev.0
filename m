From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 18 Sep 2011 23:13:58 -0400 (EDT)
Message-ID: <20110918.231358.1701611368789467684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I fixed up Eric's build fix and also there is a fix for a
reversed test in TCP's DSACK validation from Zheng Yan.

Please pull, thanks a lot!

The following changes since commit b0e7031ac08fa0aa242531c8d9a0cf9ae8ee276d:

  Merge git://github.com/davem330/net (2011-09-18 11:02:26 -0700)

are available in the git repository at:

  git://github.com/davem330/net.git master

Eric Dumazet (1):
      tcp: fix build error if !CONFIG_SYN_COOKIES

Zheng Yan (1):
      tcp: fix validation of D-SACK

 include/net/tcp.h    |   19 ++++++++++++++++++-
 net/ipv4/tcp_input.c |    2 +-
 2 files changed, 19 insertions(+), 2 deletions(-)
