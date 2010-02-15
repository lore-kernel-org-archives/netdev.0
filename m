From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/4] Improvements to octeon_ethernet.
Date: Mon, 15 Feb 2010 12:12:22 -0800
Message-ID: <4B79AAA6.60005@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: ralf.baechle@gmail.com, linux-mips <linux-mips@linux-mips.org>,
	Netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19931 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140Ab0BOUMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:12:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are a couple of improvements to the octeon_ethernet in
drivers/staging/octeon.  The first patch is just cleanup, the rest are
genuine bug fixes.

I will reply with the four patches.

We may want to merge via Ralf's linux-mips.org tree as Octeon is
infact a MIPS based SOC and he has a bunch of other patches queued
there that these depend on.

David Daney (4):
   Staging: octeon: remove unneeded includes
   Staging: Octeon:  Run phy bus accesses on a workqueue.
   MIPS: Octeon: Do proper acknowledgment of CIU timer interrupts.
   Staging: Octeon:  Free transmit SKBs in a timely manner.

  arch/mips/cavium-octeon/octeon-irq.c      |   67 +++++++++++++-
  drivers/staging/octeon/Kconfig            |    1 -
  drivers/staging/octeon/ethernet-defines.h |    5 +-
  drivers/staging/octeon/ethernet-mdio.h    |    1 -
  drivers/staging/octeon/ethernet-rgmii.c   |   56 +++++++++---
  drivers/staging/octeon/ethernet-sgmii.c   |    1 -
  drivers/staging/octeon/ethernet-spi.c     |    1 -
  drivers/staging/octeon/ethernet-tx.c      |  137 
++++++++++++++++++++++------
  drivers/staging/octeon/ethernet-tx.h      |    6 +-
  drivers/staging/octeon/ethernet-xaui.c    |    1 -
  drivers/staging/octeon/ethernet.c         |  141 
++++++++++++++++-------------
  drivers/staging/octeon/octeon-ethernet.h  |   11 ++-
  12 files changed, 303 insertions(+), 125 deletions(-)
