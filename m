From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Sat, 14 Jul 2012 00:47:41 -0700
Message-ID: <1342252063-27023-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58028 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755838Ab2GNHrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 03:47:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to e1000e.

The following are changes since commit 7ac2908e4b2edaec60e9090ddb4d9ceb76c05e7d:
  sch_sfb: Fix missing NULL check
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Bruce Allan (1):
  e1000e: fix test for PHY being accessible on 82577/8/9 and I217

Tushar Dave (1):
  e1000e: Correct link check logic for 82571 serdes

 drivers/net/ethernet/intel/e1000e/82571.c   |    3 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   42 ++++++++++++++++++++-------
 2 files changed, 35 insertions(+), 10 deletions(-)

-- 
1.7.10.4
