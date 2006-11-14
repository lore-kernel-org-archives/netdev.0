From: Stephen Hemminger <shemminger@osdl.org>
Subject: netpoll patches.
Date: Tue, 14 Nov 2006 13:55:00 -0800
Message-ID: <20061114135500.5c6b17bc@dxpl.pdx.osdl.net>
References: <20061026180402.32c1c511@localhost.localdomain>
	<20061026.180812.34605098.davem@davemloft.net>
	<20061026192934.58c20e2a@localhost.localdomain>
	<20061113.170041.17866097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61322 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S966408AbWKNVzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 16:55:08 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061113.170041.17866097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 5d1be92267c04a86232969710e32b6f99bb4ec12:
  Peter Zijlstra:
        [SCTP]: Cleanup of the sctp state table code.

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/netpoll-2.6.20

Stephen Hemminger:
      netpoll: private skb pool (rev3)
      netpoll info leak
      netpoll per device txq
      netpoll setup error handling
      netpoll deferred transmit path
      netpoll retry cleanup
      netpoll queue cleanup
      netpoll header cleanup

 drivers/net/netconsole.c |    8 +-
 include/linux/netpoll.h  |   15 ++-
 net/core/netpoll.c       |  233 +++++++++++++++++++++-------------------------
 3 files changed, 121 insertions(+), 135 deletions(-)
