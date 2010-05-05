From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/6] netdev: octeon_mgmt: A few fixes for 2.6.35.
Date: Wed,  5 May 2010 16:03:07 -0700
Message-ID: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1664 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757725Ab0EEXDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 1/6 corrects a compile error that seems to have crept
in, as well as correcting the dev_addrs/uc snafu.

2/6 - 5/6 are some other small bug fixes.

6/6 just re-formats the code some.

They are relative to commit 0a12761bcd5646691c5d16dd93df84d1b8849285
in net-next-2.6/master

If OK please apply.

Thanks,
David Daney

David Daney (6):
  netdev: octeon_mgmt: Use proper MAC addresses.
  netdev: octeon_mgmt: Fix race condition freeing TX buffers.
  netdev: octeon_mgmt: Fix race manipulating irq bits.
  netdev: octeon_mgmt: Free TX skbufs in a timely manner.
  netdev: octeon_mgmt: Try not to drop TX packets when stopping the
    queue.
  netdev: octeon_mgmt: Remove some gratuitous blank lines.

 drivers/net/octeon/octeon_mgmt.c |   57 ++++++++++++++++++-------------------
 1 files changed, 28 insertions(+), 29 deletions(-)

