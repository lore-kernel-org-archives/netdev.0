From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 647/682] fib_semantics.c:undefined reference
 to `__divdi3'
Date: Mon, 05 Oct 2015 04:26:38 -0700 (PDT)
Message-ID: <20151005.042638.1280563834697071426.davem@davemloft.net>
References: <201510051816.pL2fiACx%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pch@ordbogen.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbJELLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 07:11:00 -0400
In-Reply-To: <201510051816.pL2fiACx%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Mon, 5 Oct 2015 18:54:18 +0800

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   937317c7c1097aa878a5000e3aab616eb5c590c0
> commit: 0e884c78ee19e902f300ed147083c28a0c6302f0 [647/682] ipv4: L3 hash-based multipath
> config: i386-defconfig (attached as .config)
> reproduce:
>         git checkout 0e884c78ee19e902f300ed147083c28a0c6302f0
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    net/built-in.o: In function `fib_rebalance':
>>> fib_semantics.c:(.text+0x9df14): undefined reference to `__divdi3'

Peter please fix this.
