From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipconfig: send Client-identifier in DHCP requests
Date: Thu, 15 Oct 2015 11:34:14 +0800
Message-ID: <CAJFZqHxiPcy6Hj9n0DZrMDYo9sRUwxV-7JPoXyO_WTe4MN--ag@mail.gmail.com>
References: <1444877625-19035-1-git-send-email-roy.qing.li@gmail.com>
	<201510151117.VYwtdeyT%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, netdev <netdev@vger.kernel.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33393 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbbJODeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 23:34:15 -0400
Received: by qgeo38 with SMTP id o38so16978128qge.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 20:34:14 -0700 (PDT)
In-Reply-To: <201510151117.VYwtdeyT%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 11:27 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi Li,
>
> [auto build test WARNING on net/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]
>
> url:    https://github.com/0day-ci/linux/commits/roy-qing-li-gmail-com/ipconfig-send-Client-identifier-in-DHCP-requests/20151015-105553
> config: parisc-c3000_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=parisc
>
> All warnings (new ones prefixed by >>):
>
>>> net/ipv4/ipconfig.c:148:13: warning: 'dhcp_client_identifier' defined but not used [-Wunused-variable]
>     static char dhcp_client_identifier[253] __initdata;
>                 ^


Thanks, I will fix it

-Roy
