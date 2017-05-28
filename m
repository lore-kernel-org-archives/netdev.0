From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 3/9] net: lwtunnel: Add extack to encap attr
 validation
Date: Sat, 27 May 2017 20:44:17 -0600
Message-ID: <c2dabec6-073d-923e-263e-e029fcb23f97@gmail.com>
References: <201705280846.ceaILiWY%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35960 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbdE1CoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 22:44:24 -0400
Received: by mail-pf0-f194.google.com with SMTP id n23so8552484pfb.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 19:44:24 -0700 (PDT)
In-Reply-To: <201705280846.ceaILiWY%fengguang.wu@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/17 7:02 PM, kbuild test robot wrote:
> Hi David,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/David-Ahern/net-another-round-of-extack-handling-for-routing/20170528-062659
> config: ia64-allmodconfig (attached as .config)
> compiler: ia64-linux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 
> 
> Note: the linux-review/David-Ahern/net-another-round-of-extack-handling-for-routing/20170528-062659 HEAD 44d11f94ccbe86e1a088f83a49ef3ca473118ad8 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    ERROR: "ia64_delay_loop" [drivers/spi/spi-thunderx.ko] undefined!
>>> ERROR: "ia64_delay_loop" [drivers/net/phy/mdio-cavium.ko] undefined!

Appears to be a false positive. I do not modify anything related to
delay loops and none of this code is arch specific.

kbuild guys: can you clarify?
