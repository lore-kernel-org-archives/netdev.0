From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [wireless-testsing2:master 4/5]
 drivers/net/ethernet/marvell/mvpp2.c:7618:49: error: passing argument 4 of
 'mvpp2_port_copy_mac_addr' from incompatible pointer type
Date: Tue, 5 Sep 2017 09:29:21 -0400
Message-ID: <20170905132921.wcq5pvphd6bwczbp@localhost>
References: <201709052144.zyrDXrmL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kbuild-all@01.org,
        netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35999 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdIEN3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 09:29:23 -0400
Received: by mail-io0-f195.google.com with SMTP id 2so2984183ion.3
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 06:29:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <201709052144.zyrDXrmL%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


My fault, mismerged a driver conflict -- will fix in next w-t build.

On Tue, Sep 05, 2017 at 09:16:48PM +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/wireless/wireless-testing.git master
> head:   d17be7f7503bf9492198a242779a68af93fd92de
> commit: 96c03618031bae5e9068b16f9e437b79f98f6482 [4/5] Merge remote-tracking branch 'mac80211-next/master'
> config: ia64-allyesconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 96c03618031bae5e9068b16f9e437b79f98f6482
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/net/ethernet/marvell/mvpp2.c: In function 'mvpp2_port_probe':
> >> drivers/net/ethernet/marvell/mvpp2.c:7618:49: error: passing argument 4 of 'mvpp2_port_copy_mac_addr' from incompatible pointer type [-Werror=incompatible-pointer-types]
>      mvpp2_port_copy_mac_addr(dev, priv, port_node, &mac_from);

-- 
Bob Copeland %% https://bobcopeland.com/
