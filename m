From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 18 May 2012 23:43:00 -0400 (EDT)
Message-ID: <20120518.234300.1614262453664488027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933288Ab2ESDnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 23:43:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One last straggler.

Eric Dumazet's pktgen unload oops fix was not entirely complete, but
all the cases should be handled properly now.... fingers crossed.

Please pull, thanks a lot!

The following changes since commit 42ea7d7f2a7356962022cdd124d9043c488ca5e2:

  Merge branch 'fixes' of git://git.linaro.org/people/rmk/linux-arm (2012-05-17 16:52:29 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to d4b1133558e0d417342d5d2c49e4c35b428ff20d:

  pktgen: fix module unload for good (2012-05-18 13:54:33 -0400)

----------------------------------------------------------------
Eric Dumazet (1):
      pktgen: fix module unload for good

 net/core/pktgen.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
