From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net:master 27/28]
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1230:13-20: WARNING: kzalloc
 should be used for dcbx_info, instead of kmalloc/memset
Date: Thu, 1 Sep 2016 14:45:12 +0800
Message-ID: <201609011409.GGSqCknq%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:33258 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752318AbcIAGpX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 02:45:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   c3804289c90c1c88e447991c4c06cff6acdee7bc
commit: c5e801dac4daff972013613ae3edae6668b2aa7c [27/28] qed: Clear dcbx memory buffers before the usage.


coccinelle warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1230:13-20: WARNING: kzalloc should be used for dcbx_info, instead of kmalloc/memset
   drivers/net/ethernet/qlogic/qed/qed_dcbx.c:1192:13-20: WARNING: kzalloc should be used for dcbx_info, instead of kmalloc/memset

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
