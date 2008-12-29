From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: origin tree build warnings
Date: Sun, 28 Dec 2008 20:01:45 -0800 (PST)
Message-ID: <20081228.200145.33502228.davem@davemloft.net>
References: <20081229113525.89450db7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081229113525.89450db7.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 29 Dec 2008 11:35:25 +1100

> Hi Neil,
> 
> Today's linux-next build (powerpc ppc64_defconfig) produced these new
> warnings:
> 
> drivers/net/pasemi_mac.c: In function 'pasemi_mac_rx_intr':
> drivers/net/pasemi_mac.c:957: warning: unused variable 'dev'
> drivers/net/pasemi_mac.c: In function 'pasemi_mac_poll':
> drivers/net/pasemi_mac.c:1637: warning: unused variable 'dev'
> drivers/net/spider_net.c: In function 'spider_net_poll':
> drivers/net/spider_net.c:1280: warning: unused variable 'netdev'
> 
> Probably caused by commit 908a7a16b852ffd618a9127be8d62432182d81b4 ("net:
> Remove unused netdev arg from some NAPI interfaces").
> 
> Please fix these up.

I'll take care of all of these issues, along with the
ibmveth et al. ones you reported seperately.

Thanks Stephen.
