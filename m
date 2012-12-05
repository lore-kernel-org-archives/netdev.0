From: kbuild test robot <fengguang.wu@intel.com>
Subject: WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x1fe93):
 Section mismatch in reference from the function tg3_test_dma() to the
 variable .devinit.rodata:tg3_dma_wait_state_chipsets
Date: Wed, 05 Dec 2012 09:21:37 +0800
Message-ID: <50bea1a1.xUDXd4fkM1C9yzgn%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18618 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752446Ab2LEBWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 20:22:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   193c1e478cc496844fcbef402a10976c95a634ff
commit: 229b1ad1cb1a7159658f466c736bc3898dabb876 tg3: remove __dev* attributes
date:   30 hours ago
config: make ARCH=i386 allmodconfig

All warnings:

WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x1fe93): Section mismatch in reference from the function tg3_test_dma() to the variable .devinit.rodata:tg3_dma_wait_state_chipsets
The function tg3_test_dma() references
the variable __devinitconst tg3_dma_wait_state_chipsets.
This is often because tg3_test_dma lacks a __devinitconst
annotation or the annotation of tg3_dma_wait_state_chipsets is wrong.

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
