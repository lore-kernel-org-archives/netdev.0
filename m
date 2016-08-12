From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] rhashtable: avoid large lock-array allocations
Date: Fri, 12 Aug 2016 04:31:39 +0200
Message-ID: <20160812023139.GC5332@breakpoint.cc>
References: <1470968023-14338-1-git-send-email-fw@strlen.de>
 <201608121030.6oKJyu5a%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, kbuild-all@01.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57400 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751288AbcHLCbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 22:31:45 -0400
Content-Disposition: inline
In-Reply-To: <201608121030.6oKJyu5a%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kbuild test robot <lkp@intel.com> wrote:
> Hi Florian,
> 
> [auto build test WARNING on net/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Florian-Westphal/rhashtable-avoid-large-lock-array-allocations/20160812-101458
> config: x86_64-randconfig-x015-201632 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    In file included from lib/rhashtable.c:18:0:
>    lib/rhashtable.c: In function 'rhashtable_init':
> >> lib/rhashtable.c:34:30: warning: division by zero [-Wdiv-by-zero]
>               2 * L1_CACHE_BYTES / sizeof(spinlock_t), 1)

I will send a v2 tomorrow, perhaps its better to just go for
32UL instead of this construct after all.
