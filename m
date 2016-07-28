From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH v4] net: sched: convert qdisc linked list to hashtable
Date: Thu, 28 Jul 2016 13:18:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1607281317350.24757@cbobk.fhfr.pm>
References: <201607281957.yJSK4rUm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kbuild-all@01.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42862 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689AbcG1LSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 07:18:30 -0400
In-Reply-To: <201607281957.yJSK4rUm%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jul 2016, kbuild test robot wrote:

> [auto build test ERROR on v4.7-rc7]
> [also build test ERROR on next-20160728]
> [cannot apply to net/master net-next/master ipsec-next/master]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Jiri-Kosina/net-sched-convert-qdisc-linked-list-to-hashtable/20160728-182303
> config: i386-randconfig-s0-201630 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    net/built-in.o: In function `dev_activate':
> >> (.text+0x37ccb): undefined reference to `qdisc_hash_add'

Dear 0-day team,

could you please check my question regarding this very build failure here?

	lkml.kernel.org/r/alpine.LNX.2.00.1607141612560.24757@cbobk.fhfr.pm

Thanks,

-- 
Jiri Kosina
SUSE Labs
