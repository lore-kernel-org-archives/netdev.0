From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH V2 1/3] net: bgmac: allocate struct bgmac just once &
 don't copy it
Date: Sun, 29 Jan 2017 21:03:04 +0100
Message-ID: <6074229e-cd2f-8aca-c1d8-02795b5aa39b@gmail.com>
References: <201701290751.2sF8nmut%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, "David S . Miller" <davem@davemloft.net>,
        Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33139 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751766AbdA2ULL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 15:11:11 -0500
Received: by mail-lf0-f68.google.com with SMTP id x1so29984245lff.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 12:10:17 -0800 (PST)
In-Reply-To: <201701290751.2sF8nmut%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2017 12:40 AM, kbuild test robot wrote:
> [auto build test ERROR on net-next/master]
> [also build test ERROR on v4.10-rc5 next-20170125]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Rafa-Mi-ecki/net-next-use-one-struct-bgmac-add-PHY-support/20170129-062241
> config: i386-allmodconfig (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All error/warnings (new ones prefixed by >>):
>
>    drivers/net/ethernet/broadcom/bgmac.c: In function 'bgmac_alloc':
>>> drivers/net/ethernet/broadcom/bgmac.c:1455:12: error: implicit declaration of function 'devm_alloc_etherdev' [-Werror=implicit-function-declaration]
>      net_dev = devm_alloc_etherdev(dev, sizeof(*bgmac));
>                ^~~~~~~~~~~~~~~~~~~

Thanks, this is expected as this patch depends on
[PATCH net-next] net: add devm version of alloc_etherdev_mqs function

Let's see if net guys will find my devm_alloc_etherdev implementation
acceptable.
