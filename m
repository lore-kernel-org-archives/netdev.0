From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Please pull features branch of linux-2.6-mv643xx_eth.git
Date: Tue, 23 Oct 2007 14:20:16 -0700
Message-ID: <20071023212016.GA29970@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:35260 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751968AbXJWVUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 17:20:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following changes since commit e8b8c977734193adedf2b0f607d6252c78e86394:
  Linus Torvalds (1):
        Revert "kconfig: tristate choices with mixed tristate and boolean values"

are available in the git repository at:

  git://farnsworth.org/dale/linux-2.6-mv643xx_eth.git features

Dale Farnsworth (1):
      mv643xx_eth: Remove obsolete checksum offload comment

Lennert Buytenhek (9):
      mv643xx_eth: Split off mv643xx_eth platform device data
      mv643xx_eth: Move ethernet register definitions into private header
      mv643xx_eth: Disable RX/TX byte swapping on little-endian systems
      mv643xx_eth: Enable use on Orion platforms
      mv643xx_eth: Remove SHARED_REGS register address bias
      mv643xx_eth: Remove MV643XX_ETH_ register prefix
      mv643xx_eth: Clean up mv643xx_eth.h
      mv643xx_eth: Remove unused register defines
      mv643xx_eth: Merge drivers/net/mv643xx_eth.h into mv643xx_eth.c

 drivers/net/Kconfig         |   13 +-
 drivers/net/mv643xx_eth.c   |  806 +++++++++++++++++++++++++++++++++++--------
 drivers/net/mv643xx_eth.h   |  370 --------------------
 include/linux/mv643xx.h     |  328 +------------------
 include/linux/mv643xx_eth.h |   31 ++
 5 files changed, 709 insertions(+), 839 deletions(-)
 delete mode 100644 drivers/net/mv643xx_eth.h
 create mode 100644 include/linux/mv643xx_eth.h

It may also be viewed at:
http://www.farnsworth.org/git?p=dale/linux-2.6-mv643xx_eth.git;a=shortlog;h=features

Of course, it would be nice to get this into 2.6.24, but as a feature
addition, it could wait.

Thanks,
-Dale
