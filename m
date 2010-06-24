From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/2] Fix some section mismatch errors for Octeon network drivers
Date: Thu, 24 Jun 2010 12:14:46 -0700
Message-ID: <1277406888-26309-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:16159 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab0FXTO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 15:14:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems the kernel build system is becoming more rigorous in its
checking of section mismatches.  Please consider these two patches to
correct the problems.

The warnings were not seen under 2.6.34, so one could argue that these
are fixing a regression (although admittedly it a minor one).

David Daney (2):
  netdev: octeon_mgmt: Fix section mismatch errors.
  netdev: mdio-octeon: Fix section mismatch errors.

 drivers/net/octeon/octeon_mgmt.c |    6 +++---
 drivers/net/phy/mdio-octeon.c    |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

