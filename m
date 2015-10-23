From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2015-10-22
Date: Thu, 22 Oct 2015 18:15:51 -0700
Message-ID: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15283 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965695AbbJWBP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 21:15:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to i40e only.

Jesse provides two small fixes for i40e, first fixes counters that were
being displayed incorrectly due to indexing beyond the array of strings
when printing stats.  Then fixed the fact that the driver was printing
a message about not being able to assign VMDq because a lack of MSI-X
vectors, when it was not true.  It was due to a line missing that
initialized a variable.

The following are changes since commit 0db65fcfcded76fe4f74e3ca9f4e2baf67b683ef:
  qmi_wwan: add Sierra Wireless MC74xx/EM74xx
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Jesse Brandeburg (2):
  i40e: fix stats offsets
  i40e: fix annoying message

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 6 ++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 1 +
 2 files changed, 7 insertions(+)

-- 
2.4.3
