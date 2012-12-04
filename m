From: kbuild test robot <fengguang.wu@intel.com>
Subject: WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x16006):
 Section mismatch in reference from the function tg3_get_invariants() to the variable .devinit.rodata:tg3_write_reorder_chipsets
Date: Wed, 05 Dec 2012 04:24:21 +0800
Message-ID: <50be5bf5./vbd9l3rQvm4EYDg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26035 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757Ab2LDUZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 15:25:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   193c1e478cc496844fcbef402a10976c95a634ff
commit: 229b1ad1cb1a7159658f466c736bc3898dabb876 tg3: remove __dev* attributes
date:   25 hours ago
config: make ARCH=x86_64 allmodconfig

All warnings:

WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x16006): Section mismatch in reference from the function tg3_get_invariants() to the variable .devinit.rodata:tg3_write_reorder_chipsets
The function tg3_get_invariants() references
the variable __devinitconst tg3_write_reorder_chipsets.
This is often because tg3_get_invariants lacks a __devinitconst
annotation or the annotation of tg3_write_reorder_chipsets is wrong.
--
WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x231db): Section mismatch in reference from the function tg3_init_one() to the variable .devinit.rodata:tg3_dma_wait_state_chipsets
The function tg3_init_one() references
the variable __devinitconst tg3_dma_wait_state_chipsets.
This is often because tg3_init_one lacks a __devinitconst
annotation or the annotation of tg3_dma_wait_state_chipsets is wrong.

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
