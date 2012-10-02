From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2012-10-02
Date: Tue, 2 Oct 2012 02:25:44 +0100
Message-ID: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17087 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752282Ab2JBBZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:25:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit abb17e6c0c7b27693201dc85f75dbb184279fd10:

  netlink: use <linux/export.h> instead of <linux/module.h> (2012-09-21 15:43:58 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

(commit 6ac7ef1487a040483d89a95045efc5185a71268f)

Some bug fixes that should go into 3.7:

1. Fix oops when removing device with SR-IOV enabled.  (This regression
was introduced by the last set of changes, so the fix does not need to
be applied to any earlier kernel versions.)
2. Fix firmware structure field lookup bug that resulted in missing
sensor information.
3. Fix bug that makes self-test do very little in some configurations.
4. Fix the numbering of ethtool RX flow steering filters to reflect the
real hardware priorities.

Ben.

Ben Hutchings (6):
      sfc: Fix null function pointer in efx_sriov_channel_type
      sfc: Add parentheses around use of bitfield macro arguments
      sfc: Fix MCDI structure field lookup
      sfc: Fix loopback self-test with separate_tx_channels=1
      sfc: Remove EFX_FILTER_FLAG_RX_OVERRIDE_IP
      sfc: Fix the reported priorities of different filter types

 drivers/net/ethernet/sfc/bitfield.h    |   22 +++---
 drivers/net/ethernet/sfc/ethtool.c     |   11 +--
 drivers/net/ethernet/sfc/filter.c      |  108 ++++++++++++++++----------------
 drivers/net/ethernet/sfc/filter.h      |    7 +--
 drivers/net/ethernet/sfc/mcdi.h        |    6 +-
 drivers/net/ethernet/sfc/selftest.c    |    3 +-
 drivers/net/ethernet/sfc/siena_sriov.c |    1 +
 7 files changed, 76 insertions(+), 82 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
