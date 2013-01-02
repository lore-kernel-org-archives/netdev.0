From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 42/51] (.text+0x2684bf): multiple definition of
 `pci_get_domain_bus_and_slot'
Date: Wed, 02 Jan 2013 19:34:54 +0800
Message-ID: <50e41b5e.SvFnJqKtIV4sMTQe%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sritej Velaga <sritej.velaga@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42572 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327Ab3ABLhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 06:37:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   dc8ba109064b1473293402921169dc96aff7e691
commit: 13159183ec7afe03ed48d3b083b255278f429b5a [42/51] qlcnic: 83xx base driver
config: make ARCH=i386 allyesconfig

All error/warnings:

drivers/net/built-in.o: In function `pci_get_domain_bus_and_slot':
(.text+0x2684bf): multiple definition of `pci_get_domain_bus_and_slot'
drivers/pci/built-in.o:(.text+0x8012): first defined here

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
