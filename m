From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net:master 15/18]
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1267:13-20: WARNING: kzalloc
 should be used for dcbx_info, instead of kmalloc/memset
Date: Fri, 21 Apr 2017 08:20:07 +0800
Message-ID: <201704210853.tUPLU4Mh%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: "sudarsana.kalluru@cavium.com" <sudarsana.kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28257 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031188AbdDUAUp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 20:20:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   e0535ce58b92d7baf0b33284a6c4f8f0338f943e
commit: 62289ba27558553871fd047baadaaeda886c6a63 [15/18] qed: Fix possible system hang in the dcbnl-getdcbx() path.


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1267:13-20: WARNING: kzalloc should be used for dcbx_info, instead of kmalloc/memset

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
