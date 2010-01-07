From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/3] Staging: Improvments to Octeon Ethernet driver.
Date: Wed, 06 Jan 2010 16:55:15 -0800
Message-ID: <4B4530F3.1070701@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>,
	Netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:10975 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932616Ab0AGAzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 19:55:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches attempt to cleanup and improve the octeon-ethernet
driver in staging.  The first patch fixes up octeon interrupt handling
in preparation for the following patches.  The second and third
patches convert to NAPI and enable scatter-gather as well is cleaning
up some ugly garbage.

Since Octeon is a MIPS based SOC, we might want to merge the entire
series via Ralf's linux-mips.org tree.

I will reply with the three patches.

David Daney (3):
   MIPS: Octeon: Fix EIO handling.
   Staging: Octeon Ethernet: Clean up and convert to NAPI.
   Staging: Octeon Ethernet: Enable scatter-gather.

  arch/mips/cavium-octeon/octeon-irq.c      |   40 +++-
  drivers/staging/octeon/Kconfig            |    1 +
  drivers/staging/octeon/ethernet-defines.h |   28 ---
  drivers/staging/octeon/ethernet-mem.c     |   89 +++-----
  drivers/staging/octeon/ethernet-rx.c      |  377 
++++++++++++++++------------
  drivers/staging/octeon/ethernet-rx.h      |   25 ++-
  drivers/staging/octeon/ethernet-tx.c      |  330 ++++++++++++-------------
  drivers/staging/octeon/ethernet-tx.h      |   27 +--
  drivers/staging/octeon/ethernet.c         |  157 +++++--------
  drivers/staging/octeon/octeon-ethernet.h  |   48 +---
  10 files changed, 532 insertions(+), 590 deletions(-)

