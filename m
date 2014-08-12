From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/6][pull request] Intel Wired LAN Driver Updates 2014-08-12
Date: Tue, 12 Aug 2014 01:38:21 -0700
Message-ID: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48371 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbaHLIid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 04:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and e1000e.

Lucas provides a fix for i40e to resolve a compile issue where a header
was missing in the #includes.

Wei Yongjun provides a fix for i40e to resolve a sparse warning, where
a non-static function should be static.

Julia Lawall provides a fix for i40e which was found using Coccinelle,
where there was a typo in the name of the type given to sizeof().

Rickard Strandqvist provides a fix for i40e to replace the use of
strncpy() with strlcpy() to avoid strings that lack null termination.

Jean Sacren provides two e1000e fixes, first is a comment fix and second
removes an excessive space character in a debug message.

The following are changes since commit 61dac43ee6bedd8507294c7af8959157b686c221:
  Merge branch 'bcmgenet'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Jean Sacren (2):
  e1000e: fix trivial kernel doc typos
  e1000e: delete excessive space character in debug message

Julia Lawall (1):
  i40e: use correct structure type name in sizeof

Lucas Tanure (1):
  i40e: Fix missing uapi/linux/dcbnl.h include in i40e_fcoe.c

Rickard Strandqvist (1):
  i40e: Cleaning up missing null-terminate in conjunction with strncpy

Wei Yongjun (1):
  i40e: fix sparse non static symbol warning

 drivers/net/ethernet/intel/e1000e/manage.c  |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 +++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c  |  6 +++---
 4 files changed, 15 insertions(+), 14 deletions(-)

-- 
1.9.3
