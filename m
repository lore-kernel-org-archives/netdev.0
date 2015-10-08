From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/4] net: SO_INCOMING_CPU setsockopt()
 support
Date: Thu, 08 Oct 2015 15:24:13 -0700
Message-ID: <1444343053.27760.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201510090613.liYbSvmH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33077 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbJHWYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 18:24:15 -0400
Received: by pacex6 with SMTP id ex6so66518281pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 15:24:14 -0700 (PDT)
In-Reply-To: <201510090613.liYbSvmH%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-09 at 06:14 +0800, kbuild test robot wrote:
> Hi Eric,
> 
> [auto build test WARNING on net-next/master -- if it's inappropriate base, please ignore]
> 
> config: sh-titan_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
> 
> All warnings (new ones prefixed by >>):
> 
>    net/ipv6/udp.c: In function 'udp6_lib_lookup2':
> >> net/ipv6/udp.c:276:1: warning: label 'exact_match' defined but not used [-Wunused-label]

Oh right, I'll send a V3 then.
