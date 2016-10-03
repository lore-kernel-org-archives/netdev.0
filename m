From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/2][pull request] 100GbE Intel Wired LAN Driver Updates 2016-10-02
Date: Sun,  2 Oct 2016 23:40:41 -0700
Message-ID: <1475476843-23405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41818 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751454AbcJCGkp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 02:40:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jake fixes an issue where PTP applications requesting software timestamps
may complain that the requested mode is not supported, so add a generic
callback for those drivers that have software transmit timestamp support
enabled.  Then provides a trivial cleanup where a code was not wrapped
properly.  Got make sure that code looks good in a 80 character limit.

The following are changes since commit 7c70c4f8b2bf5ed777120f3d70efe35e64930c10:
  cxgb4: unexport cxgb4_dcb_enabled
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (2):
  fm10k: use generic ethtool_op_get_ts_info callback
  fm10k: wrap long line for alloc_workqueue

 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

-- 
2.7.4
