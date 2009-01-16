From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 16 Jan 2009 11:24:37 -0800 (PST)
Message-ID: <20090116.112437.87234989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932478AbZAPTYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 14:24:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Two quick netxen fixes, one for a build failure reported by Ingo.

Please pull, thanks a lot!

The following changes since commit a58c891a53aca81c78f9cbe0572a301042470e96:
  Eric Dumazet (1):
        b44: GFP_DMA skb should not escape from driver

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Dhananjay Phadke (2):
      netxen: avoid invalid iounmap
      netxen: include ipv6.h (fixes build failure)

 drivers/net/netxen/netxen_nic_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)
