From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] net: marvell: Allow drivers to be built
 with COMPILE_TEST
Date: Thu, 17 Nov 2016 08:52:04 -0800
Message-ID: <9b06cae5-abd8-a9d2-5c12-573071353e62@gmail.com>
References: <201611171559.suMIPVBq%fengguang.wu@intel.com>
 <19888267.TNEXR1Cft3@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        mw@semihalf.com, gregory.clement@free-electrons.com,
        Shaohui.Xie@freescale.com
To: Arnd Bergmann <arnd@arndb.de>, kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34448 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932132AbcKQRDc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:03:32 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so11986253pfb.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 09:03:31 -0800 (PST)
In-Reply-To: <19888267.TNEXR1Cft3@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 01:12 AM, Arnd Bergmann wrote:
> On Thursday, November 17, 2016 3:10:10 PM CET kbuild test robot wrote:
>> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-fsl-Allow-most-drivers-to-be-built-with-COMPILE_TEST/20161116-094841
>> config: mips-allyesconfig (attached as .config)
>> compiler: mips-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=mips 
>>
>> All errors (new ones prefixed by >>):
>>
>>    drivers/built-in.o: In function `mvneta_bm_pool_create':
>>>> mvneta_bm.c:(.text+0x772f0c): undefined reference to `mvebu_mbus_get_dram_win_info'
> 
> We should fix this, I'd suggest either adding an inline wrapper for
> mvebu_mbus_get_dram_win_info() when CONFIG_MVEBU_MBUS is not set,
> or allowing CONFIG_MVEBU_MBUS to be enabled for COMPILE_TEST as well.

Yes, I have a patch prepared for that, thanks!
-- 
Florian
