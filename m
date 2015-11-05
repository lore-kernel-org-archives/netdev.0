From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 1/5] stmmac: replace all pr_xxx by their netdev_xxx
 counterpart
Date: Thu, 5 Nov 2015 13:29:20 +0100
Message-ID: <20151105122920.GB12736@Red>
References: <1446712209-28890-2-git-send-email-clabbe.montjoie@gmail.com>
 <201511051818.nxWLifh7%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201511051818.nxWLifh7%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 05, 2015 at 06:58:17PM +0800, kbuild test robot wrote:
> Hi LABBE,
> 
> [auto build test ERROR on: net/master]
> [also build test ERROR on: v4.3 next-20151105]
> 
> url:    https://github.com/0day-ci/linux/commits/LABBE-Corentin/stmmac-replace-all-pr_xxx-by-their-netdev_xxx-counterpart/20151105-163344
> config: m68k-allyesconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=m68k 
> 
> Note: the linux-review/LABBE-Corentin/stmmac-replace-all-pr_xxx-by-their-netdev_xxx-counterpart/20151105-163344 HEAD 6d5b68276276235c73d865a816807f6073f341e9 builds fine.
>       It only hurts bisectibility.
> 
> All error/warnings (new ones prefixed by >>):
> 
>    drivers/net/ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_open':
> >> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1822:7: error: expected ')' before '__func__'
>           __func__);
>           ^
> >> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c:1822:7: warning: format '%s' expects a matching 'char *' argument [-Wformat=]
> 
> vim +1822 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> 
>   1816		priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
>   1817		priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
>   1818	
>   1819		ret = alloc_dma_desc_resources(priv);
>   1820		if (ret < 0) {
>   1821			netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n"
> > 1822				   __func__);
>   1823			goto dma_desc_error;
>   1824		}
>   1825	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

This part is removed by subsequent patch.
I will send a fixed version.

Regards
