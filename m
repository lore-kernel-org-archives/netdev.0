From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: Re: [PATCH 3/4] clk: hix5hd2: change ethernet clock type
Date: Mon, 15 Aug 2016 15:49:34 +0800
Message-ID: <57B1740E.6070501@hisilicon.com>
References: <201608112002.qeCiGZLQ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <kbuild-all-JC7UmRfGjtg@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
	<xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<howell.yang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201608112002.qeCiGZLQ%fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

On 2016/8/11 20:09, kbuild test robot wrote:
> Hi Dongpo,
> 
> [auto build test ERROR on robh/for-next]
> [also build test ERROR on v4.8-rc1 next-20160811]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Dongpo-Li/net-hix5hd2_gmac-add-tx-sg-feature-and-reset-clock-control-signals/20160811-170826
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/robh/linux.git for-next
> config: arm-multi_v7_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 5.4.0-6) 5.4.0 20160609
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/clk/hisilicon/clk-hix5hd2.c: In function 'hix5hd2_clk_init':
>>> drivers/clk/hisilicon/clk-hix5hd2.c:260:25: error: passing argument 1 of 'hisi_reset_init' from incompatible pointer type [-Werror=incompatible-pointer-types]
>      rstc = hisi_reset_init(np);
>                             ^
>    In file included from drivers/clk/hisilicon/clk-hix5hd2.c:15:0:
>    drivers/clk/hisilicon/reset.h:25:31: note: expected 'struct platform_device *' but argument is of type 'struct device_node *'
>     struct hisi_reset_controller *hisi_reset_init(struct platform_device *pdev);
>                                   ^

Sorry for my mistake, the interface changes in newer patch. I will fix my problem in the next patch version.


    Regards,
    Dongpo

.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
