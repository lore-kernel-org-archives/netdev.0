From: arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [v1] net:ethernet:cavium:octeon:octeon_mgmt: Handle return NULL
 error from devm_ioremap
Date: Wed, 14 Dec 2016 22:00:13 +0530
Message-ID: <9d927b90-2460-ce17-89ab-53db3cc5230e@gmail.com>
References: <201612142225.IaytQyYf%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, peter.chen@nxp.com, fw@strlen.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201612142225.IaytQyYf%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for build failure. I have send new changes. Which does not
this failure.

Thanks
-Arvind

On Wednesday 14 December 2016 08:10 PM, kbuild test robot wrote:
> Hi Arvind,
>
> [auto build test ERROR on net-next/master]
> [also build test ERROR on v4.9 next-20161214]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Arvind-Yadav/net-ethernet-cavium-octeon-octeon_mgmt-Handle-return-NULL-error-from-devm_ioremap/20161213-224624
> config: mips-cavium_octeon_defconfig (attached as .config)
> compiler: mips64-linux-gnuabi64-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=mips
>
> All errors (new ones prefixed by >>):
>
>     drivers/net/ethernet/cavium/octeon/octeon_mgmt.c: In function 'octeon_mgmt_probe':
>>> drivers/net/ethernet/cavium/octeon/octeon_mgmt.c:1473:11: error: 'dev' undeclared (first use in this function)
>        dev_err(dev, "failed to map I/O memory\n");
>                ^~~
>     drivers/net/ethernet/cavium/octeon/octeon_mgmt.c:1473:11: note: each undeclared identifier is reported only once for each function it appears in
>
> vim +/dev +1473 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>
>    1467	
>    1468		p->mix = (u64)devm_ioremap(&pdev->dev, p->mix_phys, p->mix_size);
>    1469		p->agl = (u64)devm_ioremap(&pdev->dev, p->agl_phys, p->agl_size);
>    1470		p->agl_prt_ctl = (u64)devm_ioremap(&pdev->dev, p->agl_prt_ctl_phys,
>    1471						   p->agl_prt_ctl_size);
>    1472		if (!p->mix || !p->agl || !p->agl_prt_ctl) {
>> 1473			dev_err(dev, "failed to map I/O memory\n");
>    1474			result = -ENOMEM;
>    1475			goto err;
>    1476		}
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
