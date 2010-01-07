From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/7] Staging: Improvments to Octeon Ethernet driver (second
 attempt).
Date: Thu, 07 Jan 2010 11:03:33 -0800
Message-ID: <4B463005.8060505@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>,
	Netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17060 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab0AGTEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:04:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches attempt to cleanup and improve the octeon-ethernet
driver in staging.  The first patch fixes up Octeon interrupt handling
in preparation for the following patches.  At David Miller's
suggestion I have factored the changes into many more individual
patches than I had in the first version.

Since Octeon is a MIPS based SOC, we might want to merge the entire
series via Ralf's linux-mips.org tree.

I will reply with the seven patches.

David Daney (7):
   MIPS: Octeon: Fix EIO handling.
   Staging: Octeon Ethernet: Remove unused code.
   Staging: Octeon Ethernet: Fix memory allocation.
   Staging: Octeon Ethernet: Rewrite transmit code.
   Staging: Octeon Ethernet: Convert to NAPI.
   Staging: Octeon Ethernet: Enable scatter-gather.
   Staging: Octeon Ethernet: Use constants from in.h

  arch/mips/cavium-octeon/octeon-irq.c      |   40 +++-
  drivers/staging/octeon/Kconfig            |    1 +
  drivers/staging/octeon/ethernet-defines.h |   31 ---
  drivers/staging/octeon/ethernet-mem.c     |   89 ++-----
  drivers/staging/octeon/ethernet-rx.c      |  377 
++++++++++++++++------------
  drivers/staging/octeon/ethernet-rx.h      |   25 ++-
  drivers/staging/octeon/ethernet-tx.c      |  342 
+++++++++++++-------------
  drivers/staging/octeon/ethernet-tx.h      |   27 +--
  drivers/staging/octeon/ethernet.c         |  155 +++++--------
  drivers/staging/octeon/octeon-ethernet.h  |   48 +---
  10 files changed, 537 insertions(+), 598 deletions(-)

