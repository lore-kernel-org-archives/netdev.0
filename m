From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net 3/3] netvsc: fix RCU warning from set_multicast
 (fwd)
Date: Tue, 6 Jun 2017 09:52:21 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1706060951180.3023@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>, kbuild-all@01.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:25642
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750755AbdFFHwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 03:52:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please check the indentation of lines 73 onward.

thanks,
julia

---------- Forwarded message ----------
Date: Tue, 6 Jun 2017 14:40:59 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net 3/3] netvsc: fix RCU warning from set_multicast

CC: kbuild-all@01.org
In-Reply-To: <20170605211010.9571-4-sthemmin@microsoft.com>
TO: Stephen Hemminger <stephen@networkplumber.org>
CC: davem@davemloft.net
CC: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>

Hi Stephen,

[auto build test WARNING on net/master]

url:    https://github.com/0day-ci/linux/commits/Stephen-Hemminger/netvsc-bug-fixes/20170606-120730
:::::: branch date: 3 hours ago
:::::: commit date: 3 hours ago

>> drivers/net/hyperv/netvsc_drv.c:71:2-26: code aligned with following code on line 73

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 65bcf34d2ae4e8a34c6b65dbd9efff1aee7050a2
vim +71 drivers/net/hyperv/netvsc_drv.c

65bcf34d Stephen Hemminger 2017-06-05  65  	struct netvsc_device *nvdev;
d426b2e3 Haiyang Zhang     2011-11-30  66  	struct rndis_device *rdev;
d426b2e3 Haiyang Zhang     2011-11-30  67
65bcf34d Stephen Hemminger 2017-06-05  68  	rtnl_lock();
65bcf34d Stephen Hemminger 2017-06-05  69  	nvdev = rtnl_dereference(ndevctx->nvdev);
65bcf34d Stephen Hemminger 2017-06-05  70  	if (nvdev)
d426b2e3 Haiyang Zhang     2011-11-30 @71  		rdev = nvdev->extension;
d426b2e3 Haiyang Zhang     2011-11-30  72
65bcf34d Stephen Hemminger 2017-06-05 @73  		if (rdev) {
0a1275ca Vitaly Kuznetsov  2016-05-13  74  			if (ndev->flags & IFF_PROMISC)
d426b2e3 Haiyang Zhang     2011-11-30  75  				rndis_filter_set_packet_filter(rdev,
d426b2e3 Haiyang Zhang     2011-11-30  76  							       NDIS_PACKET_TYPE_PROMISCUOUS);

:::::: The code at line 71 was first introduced by commit
:::::: d426b2e3d91f8ec3203f8852e7ad0153b5dfdf71 net/hyperv: Add support for promiscuous mode setting

:::::: TO: Haiyang Zhang <haiyangz@microsoft.com>
:::::: CC: Greg Kroah-Hartman <gregkh@suse.de>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
