From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: hisilicon: add OF dependency
Date: Fri, 16 Oct 2015 11:22:47 -0700
Message-ID: <1445019767.22921.47.camel@perches.com>
References: <201510170250.cihasszS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, kbuild-all@01.org,
	huangdaode <huangdaode@hisilicon.com>, davem@davemloft.net,
	liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com,
	linux-kernel@vger.kernel.org, lipeng321@huawei.com
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201510170250.cihasszS%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-10-17 at 02:16 +0800, kbuild test robot wrote:
> All errors (new ones prefixed by >>):
>    drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c: In function 'hns_dsaf_get_cfg':
> >> drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:151:3: error: implicit declaration of function 'iounmap' [-Werror=implicit-function-declaration]
>       iounmap(dsaf_dev->io_base);
>       ^
>    cc1: some warnings being treated as errors
> 
> vim +/iounmap +151 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
[]
> 511e6bc0 huangdaode 2015-09-17  142  	if (!dma_set_mask_and_coherent(dsaf_dev->dev, DMA_BIT_MASK(64ULL)))

btw: this should be DMA_BIT_MASK(64) without the ULL
