From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: build warning after merge of the driver-core tree
Date: Sun, 20 Feb 2011 22:32:28 -0800
Message-ID: <20110221063228.GB30091@kroah.com>
References: <20110221170226.c43175f7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Ilya Yanok <yanok@emcraft.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110221170226.c43175f7.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2011 at 05:02:26PM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> After merging the driver-core tree, today's linux-next build (x86_64
> allmodconfig) produced this warning:
> 
> drivers/net/dnet.c: In function 'dnet_mii_init':
> drivers/net/dnet.c:340: warning: passing argument 1 of 'platform_set_drvdata' from incompatible pointer type
> include/linux/platform_device.h:138: note: expected 'struct platform_device *' but argument is of type 'struct net_device *'
> 
> Revealed by commit 71d642908d4e8e7a2a4a6e0490432e719ff466d5 ("Driver
> core: convert platform_{get,set}_drvdata to static inline functions").
> Introduced by commit 4796417417a62e2ae83d92cb92e1ecf9ec67b5f5 ("dnet:
> Dave DNET ethernet controller driver (updated)").

It sounds like the driver is wrong here :(

thanks,

greg k-h
