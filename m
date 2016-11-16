From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 3/3] net: marvell: Allow drivers to be built
 with COMPILE_TEST
Date: Wed, 16 Nov 2016 12:06:17 -0800
Message-ID: <48414031-de4e-a36a-95d7-84c31f1616e4@gmail.com>
References: <201611170244.EQJKm0tn%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        mw@semihalf.com, arnd@arndb.de, Shaohui.Xie@freescale.com
To: kbuild test robot <lkp@intel.com>,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34154 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbcKPUGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 15:06:20 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so15135481pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 12:06:20 -0800 (PST)
In-Reply-To: <201611170244.EQJKm0tn%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2016 11:04 AM, kbuild test robot wrote:
> Hi Florian,
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-gianfar_ptp-Rename-FS-bit-to-FIPERST/20161116-095805
> config: s390-allyesconfig (attached as .config)
> compiler: s390x-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=s390 
> 
> All warnings (new ones prefixed by >>):

While we could fix some of these warnings for 64-bit architectures, the
mvneta and mvpp2 drivers would not work there anyway since they assume
physical addresses will always be 32-bit wide and casts such addresses
accordingly.

Should we still silence these warnings?
-- 
Florian
