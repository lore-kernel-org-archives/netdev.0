From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: hisilicon: add OF dependency
Date: Fri, 16 Oct 2015 21:10:54 +0200
Message-ID: <3752954.ncYqAxKXIS@wuerfel>
References: <201510170250.9XPqjohi%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kbuild-all@01.org, huangdaode <huangdaode@hisilicon.com>,
	davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201510170250.9XPqjohi%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 17 October 2015 02:39:51 kbuild test robot wrote:
> 
> [auto build test WARNING on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]
> 
> url:    https://github.com/0day-ci/linux/commits/Arnd-Bergmann/net-hisilicon-add-OF-dependency/20151016-173818
> config: ia64-allmodconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=ia64 
> 

I guess I should have sent my three patches as a series. The build bot
found the same two bugs I had found myself and sent fixes for, but
applying the 'add OF dependency' without the other two makes them appear
in more configurations.

For all I can see, the two reports here are fixed if all three of my
patches are applied.

	Arnd
