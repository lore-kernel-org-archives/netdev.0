From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 22 Nov 2010 12:10:42 -0800 (PST)
Message-ID: <20101122.121042.260064840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757220Ab0KVUKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 15:10:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix screaming IRQ in e1000, from Anupam Chanda.

2) Fix module parameter bustage in qlge, from Sonny Rao.

3) Interface address leak in ipv6, fix from John Fastabend.

   This would have been merged sooner except that I erroneously
   put this into my net-next-2.6 tree, oops.

4) Support for more Marvell PHY variants, from David Daney.

5) Chip variant checking fix in atl1c from Ben Hutchings.

6) Baud rate correction fix in SH-irda driver, from Nicolas Kaiser.

Please pull, thanks a lot!

The following changes since commit b86db4744230c94e480de56f1b7f31117edbf193:

  Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2010-11-19 19:46:45 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anupam Chanda (1):
      e1000: fix screaming IRQ

Ben Hutchings (1):
      atl1c: Fix hardware type check for enabling OTP CLK

David Daney (3):
      phylib: Use common page register definition for Marvell PHYs.
      phylib: Add support for Marvell 88E1149R devices.
      of/phylib: Use device tree properties to initialize Marvell PHYs.

Eric Dumazet (1):
      net: allow GFP_HIGHMEM in __vmalloc()

John Fastabend (1):
      ipv6: fix missing in6_ifa_put in addrconf

Nicolas Kaiser (1):
      SuperH IrDA: correct Baud rate error correction

Simon Horman (1):
      bonding: change list contact to netdev@vger.kernel.org

Sonny Rao (1):
      qlge: Fix incorrect usage of module parameters and netdev msg level

 MAINTAINERS                    |    2 +-
 drivers/net/atl1c/atl1c_hw.c   |    2 +-
 drivers/net/e1000/e1000_main.c |   12 ++-
 drivers/net/irda/sh_sir.c      |    2 +-
 drivers/net/phy/marvell.c      |  164 ++++++++++++++++++++++++++++++++++++---
 drivers/net/qlge/qlge_main.c   |    6 +-
 include/linux/marvell_phy.h    |    1 +
 net/ceph/buffer.c              |    2 +-
 net/core/request_sock.c        |    4 +-
 net/ipv4/fib_trie.c            |    2 +-
 net/ipv6/addrconf.c            |    6 +-
 net/xfrm/xfrm_hash.c           |    2 +-
 12 files changed, 173 insertions(+), 32 deletions(-)
