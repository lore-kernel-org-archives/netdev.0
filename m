From: kbuild test robot <fengguang.wu@intel.com>
Subject: WARNING: drivers/net/ethernet/dec/tulip/tulip.o(.text+0x6f9b):
 Section mismatch in reference from the function tulip_init_one() to the
 variable .devinit.rodata:early_486_chipsets
Date: Wed, 05 Dec 2012 08:10:30 +0800
Message-ID: <50be90f6.+7gxUjJ0gr3pAShL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:30732 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228Ab2LEAMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 19:12:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   193c1e478cc496844fcbef402a10976c95a634ff
commit: 779c1a85813a4622cc3bb3d25ce10b523bd055ba tulip: remove __dev* attributes
date:   29 hours ago
config: make ARCH=x86_64 allmodconfig

All warnings:

WARNING: drivers/net/ethernet/dec/tulip/tulip.o(.text+0x6f9b): Section mismatch in reference from the function tulip_init_one() to the variable .devinit.rodata:early_486_chipsets
The function tulip_init_one() references
the variable __devinitconst early_486_chipsets.
This is often because tulip_init_one lacks a __devinitconst
annotation or the annotation of early_486_chipsets is wrong.

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
