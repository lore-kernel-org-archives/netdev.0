From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates 2016-04-05
Date: Tue,  5 Apr 2016 15:30:48 -0700
Message-ID: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12327 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933746AbcDEWax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 18:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and e1000.

Jesse fixes an issue where code was added by a previous commit but the
flag to enable it was never set.

Alex fixes the e1000 driver from grossly overestimated the descriptors
needed to transmit a frame.

The following are changes since commit eb8e97715f29a1240cdf67b0df725be27433259f:
  sctp: use list_* in sctp_list_dequeue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Alexander Duyck (2):
  e1000: Do not overestimate descriptor counts in Tx pre-check
  e1000: Double Tx descriptors needed check for 82544

Jesse Brandeburg (1):
  i40e: fix errant PCIe bandwidth message

 drivers/net/ethernet/intel/e1000/e1000_main.c | 21 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  1 +
 2 files changed, 20 insertions(+), 2 deletions(-)

-- 
2.5.5
