From: Dale Farnsworth <dale@farnsworth.org>
Subject: Please pull for-2.6.26 branch of linux-2.6-mv643xx_eth.git
Date: Tue, 1 Apr 2008 12:03:14 -0700
Message-ID: <20080401190314.GA13017@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@marvell.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:53653 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020AbYDATD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 15:03:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Please pull from the following git repository:
  git://git.farnsworth.org/dale/linux-2.6-mv643xx_eth.git for-2.6.26

It contains the commits below, which were previously posted on netdev.

Thanks,
-Dale


Lennert Buytenhek (7):
      mv643xx_eth: mp->tx_desc_count needs spinlock protection
      mv643xx_eth: various cleanups
      mv643xx_eth: identify ports by struct mv643xx_private *
      mv643xx_eth: report netdev name in all printks
      mv643xx_eth: pass port identifier to register accessors
      mv643xx_eth: only print banner once
      mv643xx_eth: update copyright

 drivers/net/mv643xx_eth.c |  473 ++++++++++++++++++++++-----------------------
 1 files changed, 230 insertions(+), 243 deletions(-)
