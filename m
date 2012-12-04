From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: drivers/net/ethernet/broadcom/tg3.o(.text+0x16006):
 Section mismatch in reference from the function tg3_get_invariants() to
 the variable .devinit.rodata:tg3_write_reorder_chipsets
Date: Tue, 04 Dec 2012 15:28:25 -0500 (EST)
Message-ID: <20121204.152825.1014358628158241121.davem@davemloft.net>
References: <50be5bf5./vbd9l3rQvm4EYDg%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfp5p@virginia.edu, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751Ab2LDU23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:28:29 -0500
In-Reply-To: <50be5bf5./vbd9l3rQvm4EYDg%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Wed, 05 Dec 2012 04:24:21 +0800

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   193c1e478cc496844fcbef402a10976c95a634ff
> commit: 229b1ad1cb1a7159658f466c736bc3898dabb876 tg3: remove __dev* attributes
> date:   25 hours ago
> config: make ARCH=x86_64 allmodconfig
> 
> All warnings:

This is a result of the __dev* macro removal from the networking
drivers.  I think it will be resolved when Greg KH's tree gets merged.

The issue is that the PCI device ID macros in linux/pci.h still
use the __dev* tags.

Greg, please confirm.
