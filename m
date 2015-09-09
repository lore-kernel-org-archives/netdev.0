From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net:master 30/34] net/ipv6/route.c:2946:3-8: WARNING: NULL check
 before freeing functions like kfree, debugfs_remove,
 debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider
 reorganizing relevant code to avoid passing NULL values.
Date: Thu, 10 Sep 2015 06:57:12 +0800
Message-ID: <201509100609.fhjHrskx%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17177 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbbIIW6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 18:58:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   f53de1e9a4aaf8cbe08845da6f7ff26a078ac507
commit: 6b9ea5a64ed5eeb3f68f2e6fcce0ed1179801d1e [30/34] ipv6: fix multipath route replace error recovery


coccinelle warnings: (new ones prefixed by >>)

>> net/ipv6/route.c:2946:3-8: WARNING: NULL check before freeing functions like kfree, debugfs_remove, debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider reorganizing relevant code to avoid passing NULL values.

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
