From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Thu, 02 Sep 2010 19:14:19 -0700 (PDT)
Message-ID: <20100902.191419.212687669.davem@davemloft.net>
References: <20100903114750.3d8994b7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100903114750.3d8994b7.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 3 Sep 2010 11:47:50 +1000

> Hi all,
> 
> After merging the final tree, next-20100830 and later builds (s390
> allmodconfig) failed like this:
> 
> drivers/net/stmmac/stmmac_main.c: In function 'stmmac_adjust_link':
> drivers/net/stmmac/stmmac_main.c:217: error: implicit declaration of function 'readl'
> drivers/net/stmmac/stmmac_main.c:270: error: implicit declaration of function 'writel'
> drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
> drivers/net/stmmac/stmmac_main.c:1676: error: implicit declaration of function 'ioremap'
> drivers/net/stmmac/stmmac_main.c:1676: warning: assignment makes pointer from integer without a cast
> drivers/net/stmmac/stmmac_main.c:1744: warning: cast from pointer to integer of different size
> drivers/net/stmmac/stmmac_main.c:1760: error: implicit declaration of function 'iounmap'
> 
> Exposed by commit ac75791aa943c7953521cb4fa7728bf51f9abd2d ("stmmac:
> remove dead option in the driver's Kconfig")  That allowed the driver to
> be built on a lot more platforms that previously.

I'll make it's Kconfig depend upon the arch having IOMEM or something like
that, thanks.
