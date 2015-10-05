From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/5] net: Refactor path selection in
 __ip_route_output_key
Date: Mon, 05 Oct 2015 06:38:36 -0700 (PDT)
Message-ID: <20151005.063836.1612675139838377064.davem@davemloft.net>
References: <1443713247-11230-4-git-send-email-dsa@cumulusnetworks.com>
	<201510021431.hGNWKbMp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, kbuild-all@01.org, netdev@vger.kernel.org,
	dsahern@gmail.com
To: lkp@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbJENW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:22:57 -0400
In-Reply-To: <201510021431.hGNWKbMp%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <lkp@intel.com>
Date: Fri, 2 Oct 2015 14:20:30 +0800

> Hi David,
> 
> [auto build test results on next-20151001 -- if it's inappropriate base, please ignore]
> 
> config: mips-nlm_xlp_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=mips 
> 
> All warnings (new ones prefixed by >>):
> 
>>> mips-linux-gnu-ld: net/ipv4/.tmp_fib_semantics.o: warning: Inconsistent ISA between e_flags and .MIPS.abiflags

Frankly this looks like a build infrastructure or tools bug to me.
