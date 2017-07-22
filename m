From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 1/3] bluetooth: 6lowpan dev_close never returns
 error
Date: Sat, 22 Jul 2017 08:42:37 +0200
Message-ID: <9F800AAB-D2D1-4131-A6CD-01B16CAEF78D@holtmann.org>
References: <201707211821.oD6w3YMa%fengguang.wu@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>, kbuild-all@01.org,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        "David S. Miller" <davem@davemloft.net>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:38171 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752241AbdGVGmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 02:42:40 -0400
In-Reply-To: <201707211821.oD6w3YMa%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Stephen-Hemminger/net-make-dev_close-void/20170720-090123
> config: x86_64-randconfig-a0-07211734 (attached as .config)
> compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
> reproduce:
>        # save the attached .config to linux build tree
>        make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>   net/bluetooth/6lowpan.c: In function 'ifdown':
>>> net/bluetooth/6lowpan.c:621: warning: unused variable 'err'
> 
> vim +/err +621 net/bluetooth/6lowpan.c
> 
> 18722c24 Jukka Rissanen    2013-12-11  618  
> 7f118253 Jukka Rissanen    2014-06-18  619  static void ifdown(struct net_device *netdev)
> 7f118253 Jukka Rissanen    2014-06-18  620  {
> 7f118253 Jukka Rissanen    2014-06-18 @621  	int err;
> 7f118253 Jukka Rissanen    2014-06-18  622  
> 7f118253 Jukka Rissanen    2014-06-18  623  	rtnl_lock();
> ca74f73e Stephen Hemminger 2017-07-18  624  	dev_close(netdev);
> 7f118253 Jukka Rissanen    2014-06-18  625  	rtnl_unlock();
> 7f118253 Jukka Rissanen    2014-06-18  626  }
> 7f118253 Jukka Rissanen    2014-06-18  627  
> 
> :::::: The code at line 621 was first introduced by commit
> :::::: 7f118253820fc3ad38659485adb3ebdfe64820e1 Bluetooth: 6LoWPAN: Remove network devices when unloading
> 
> :::::: TO: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> :::::: CC: Marcel Holtmann <marcel@holtmann.org>

are you going to send a fix for this?

Regards

Marcel
