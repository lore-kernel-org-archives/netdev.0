From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/2] Staging: Clean up octeon Ethernet some.
Date: Tue, 16 Feb 2010 17:24:16 -0800
Message-ID: <4B7B4540.1010700@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>,
	Netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:6637 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933816Ab0BQBYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 20:24:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches clean up some comments and get rid of the code that
creates a non-standard file in /proc

As with the previous octeon_ethernet patches, these can probably go
via Ralf's linux-mips.org tree.

I will reply with the two patches.

David Daney (2):
   Staging: Octeon: Reformat a bunch of comments.
   Staging: Octeon: Remove /proc/octeon_ethernet_stats

  drivers/staging/octeon/Makefile          |    1 -
  drivers/staging/octeon/ethernet-mdio.c   |    6 +-
  drivers/staging/octeon/ethernet-mem.c    |   16 ++--
  drivers/staging/octeon/ethernet-proc.c   |  144 
------------------------------
  drivers/staging/octeon/ethernet-proc.h   |   29 ------
  drivers/staging/octeon/ethernet-rx.c     |   17 ++--
  drivers/staging/octeon/ethernet-tx.c     |   14 ++--
  drivers/staging/octeon/ethernet-util.h   |   13 +--
  drivers/staging/octeon/ethernet.c        |   46 +++-------
  drivers/staging/octeon/octeon-ethernet.h |    7 --
  10 files changed, 44 insertions(+), 249 deletions(-)
  delete mode 100644 drivers/staging/octeon/ethernet-proc.c
  delete mode 100644 drivers/staging/octeon/ethernet-proc.h

