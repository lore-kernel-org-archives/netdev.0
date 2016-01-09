From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH] phy: micrel: Fix build failure in ksz9031_config_init()
Date: Sat, 9 Jan 2016 12:55:30 +0100
Message-ID: <CA+icZUW3ay_c5_x2yjovnP=WK2_CUEsO5s4i45hc4RCmOpdSvA@mail.gmail.com>
References: <1452338674-3353-1-git-send-email-sedat.dilek@gmail.com>
	<201601091926.s6AqeVJk%fengguang.wu@intel.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Roosen Henri <Henri.Roosen@ginzinger.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:35959 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850AbcAILzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 06:55:31 -0500
Received: by mail-vk0-f51.google.com with SMTP id n1so50113630vkb.3
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 03:55:31 -0800 (PST)
In-Reply-To: <201601091926.s6AqeVJk%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 9, 2016 at 12:49 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Sedat,
>
> [auto build test ERROR on net/master]
> [cannot apply to net-next/master v4.4-rc8 next-20160108]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
>

This patch is for net.git#master not net-next or Linux-next.
I should have add a proper label, Sorry.

- Sedat -

> url:    https://github.com/0day-ci/linux/commits/Sedat-Dilek/phy-micrel-Fix-build-failure-in-ksz9031_config_init/20160109-192630
> config: x86_64-randconfig-x000-01060743 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    drivers/net/phy/micrel.c: In function 'ksz9031_config_init':
>>> drivers/net/phy/micrel.c:479:22: error: 'struct phy_device' has no member named 'mdio'
>      dev_walker = &phydev->mdio.dev;
>                          ^
>
> vim +479 drivers/net/phy/micrel.c
>
>    473          const struct device *dev_walker;
>    474
>    475          /* The Micrel driver has a deprecated option to place phy OF
>    476           * properties in the MAC node. Walk up the tree of devices to
>    477           * find a device with an OF node.
>    478           */
>  > 479          dev_walker = &phydev->mdio.dev;
>    480          do {
>    481                  of_node = dev_walker->of_node;
>    482                  dev_walker = dev_walker->parent;
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
