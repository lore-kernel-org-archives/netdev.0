From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/8] sh_eth: deal with #ifdef'fery
Date: Thu, 06 Jun 2013 16:05:04 -0700 (PDT)
Message-ID: <20130606.160504.85747659460186927.davem@davemloft.net>
References: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 6 Jun 2013 23:39:20 +0400

>    This series of 8 patches are against Dave's 'net-next.git' repository.
>    The series deals mostly with excess #ifdef'fery in the 'sh_eth' driver.
> It doesn't yet get rid of all the #ifdef'fery but that's a matter of another
> patchset. The last patch (it was almost in the middle of the series before),
> contrariwise, adds one missing #ifdef...
> 
> [1/8] sh_eth: remove #ifdef around EDSR and GECMR bit definitions
> [2/8] sh_eth: use EDSR_ENALL to set EDSR
> [3/8] sh_eth: remove duplicate sh_eth_set_duplex() definitions
> [4/8] sh_eth: remove SH_ETH_HAS_TSU
> [5/8] sh_eth: add IRQ flags to 'struct sh_eth_cpu_data'
> [6/8] sh_eth: remove #ifdef around sh_eth_select_mii()
> [7/8] sh_eth: consolidate sh_eth_reset()
> [8/8] sh_eth: enclose PM code into #ifdef CONFIG_PM

All applied, thanks.

I think you should have two sets of const netdev_ops to cover the two
cases, instead of writing to a non-const netdev_ops.  Could you send a
follow-on patch which does that?

Thanks.
