From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 07 Jul 2014 19:53:30 -0700 (PDT)
Message-ID: <20140707.195330.1593299312055099195.davem@davemloft.net>
References: <20140704113907.468a366a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vbridgers2013@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140704113907.468a366a@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 4 Jul 2014 11:39:07 +1000

> After merging the net tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> ERROR: "phy_resume" [drivers/net/ethernet/stmicro/stmmac/stmmac.ko] undefined!
> 
> Caused by commit 0acf16768740 ("net: stmmac: add platform init/exit for
> Altera's ARM socfpga").
> 
> I reverted that commit for today.

Vince you haven't made any effort to fix this build failure, so I am reverting
your changes.
