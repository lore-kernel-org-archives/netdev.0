From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-09-17
Date: Tue, 17 Sep 2013 01:10:11 +0100
Message-ID: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29314 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab3IQAKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:10:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit ba39767288661c01ac7797b6b981f73b6513cf55:

  Merge branch 'qlcnic' (2013-08-31 22:35:26 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.12

for you to fetch changes up to a915ccc9f2c80aa4c329262d89f93ea16d8792c9:

  sfc: Reinitialise and re-validate datapath caps after MC reboot (2013-09-11 15:29:53 +0100)

Some bug fixes and future-proofing for the recently added SFC9120
support:

1. Minimal support for the 40G configuration.
2. Disable the incomplete PTP/hardware timestamping support.
3. Reset MAC stats properly after a firmware upgrade.
4. Re-check the datapath firmware capabilities after the controller is
reset.

Ben.

----------------------------------------------------------------
Ben Hutchings (5):
      sfc: Minimal support for 40G link speed
      sfc: Disable PTP on EF10 until we're ready to handle inline RX timestamps
      sfc: Reset derived rx_bad_bytes statistic when EF10 MC is rebooted
      sfc: Clean up validation of datapath capabilities
      sfc: Reinitialise and re-validate datapath caps after MC reboot

 drivers/net/ethernet/sfc/Kconfig     |  2 +-
 drivers/net/ethernet/sfc/ef10.c      | 58 +++++++++++++++++++++++-------------
 drivers/net/ethernet/sfc/mcdi_port.c |  2 ++
 drivers/net/ethernet/sfc/nic.h       |  3 ++
 4 files changed, 43 insertions(+), 22 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
