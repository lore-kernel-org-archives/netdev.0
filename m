From: kbuild test robot <fengguang.wu@intel.com>
Subject: WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87):
 Section mismatch in reference from the function sundance_probe1() to the
 variable .devinit.rodata:sundance_pci_tbl
Date: Wed, 05 Dec 2012 06:23:06 +0800
Message-ID: <50be77ca.95imDYp6GlyHjRuw%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37239 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab2LDWYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 17:24:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   193c1e478cc496844fcbef402a10976c95a634ff
commit: 64bc40de134bb5c7826ff384016f654219ed3956 dlink: remove __dev* attributes
date:   27 hours ago
config: make ARCH=x86_64 allmodconfig

All warnings:

WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87): Section mismatch in reference from the function sundance_probe1() to the variable .devinit.rodata:sundance_pci_tbl
The function sundance_probe1() references
the variable __devinitconst sundance_pci_tbl.
This is often because sundance_probe1 lacks a __devinitconst
annotation or the annotation of sundance_pci_tbl is wrong.

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
