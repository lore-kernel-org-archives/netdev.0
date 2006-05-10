From: Stephen Hemminger <shemminger@osdl.org>
Subject: please pull upstream branch of netdev-2.6
Date: Wed, 10 May 2006 14:55:59 -0700
Message-ID: <20060510145559.764017c6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:641 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964939AbWEJV4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 17:56:00 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k4ALtxtH016406
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 10 May 2006 14:55:59 -0700
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 6810b548b25114607e0814612d84125abccc0a4f:
  Andi Kleen:
        x86_64: Move ondemand timer into own work queue

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/netdev-2.6.git upstream

Francois Romieu:
      dl2k: use DMA_48BIT_MASK constant

Herbert Valerio Riedel:
      phy: mdiobus_register(): initialize all phy_map entries

James Cameron:
      sis900: phy for FoxCon motherboard

Stephen Hemminger:
      sky2: ifdown kills irq mask

 drivers/net/dl2k.c          |   12 ++++++------
 drivers/net/phy/mdio_bus.c  |    4 +++-
 drivers/net/sis900.c        |    1 +
 drivers/net/sky2.c          |    5 +++--
 include/linux/dma-mapping.h |    1 +
 5 files changed, 14 insertions(+), 9 deletions(-)
