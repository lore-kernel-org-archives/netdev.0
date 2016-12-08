From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [PATCH 0/3] i40e: Support for XDP
Date: Thu,  8 Dec 2016 18:00:19 +0100
Message-ID: <20161208170022.11555-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        john.r.fastabend@intel.com, magnus.karlsson@intel.com,
        netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40186 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753582AbcLHRBG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 12:01:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

This series adds XDP support for i40e-based NICs.

The first patch adds XDP_RX support, the second XDP_TX support and the
last patch makes it possible to change an XDP program without
rebuilding the rings.


Björn


Björn Töpel (3):
  i40e: Initial support for XDP
  i40e: Add XDP_TX support
  i40e: Don't reset/rebuild rings on XDP program swap

 drivers/net/ethernet/intel/i40e/i40e.h         |  18 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   3 +
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 358 +++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 445 +++++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   7 +
 5 files changed, 715 insertions(+), 116 deletions(-)

-- 
2.9.3
