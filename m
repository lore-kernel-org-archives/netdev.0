From: Ilya Yanok <yanok@emcraft.com>
Subject: Re: linux-next: build warning after merge of the driver-core tree
Date: Mon, 21 Feb 2011 23:18:31 +0300
Message-ID: <4D62C897.5020707@emcraft.com>
References: <20110221170226.c43175f7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110221170226.c43175f7.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen, Greg,

On 21.02.2011 09:02, Stephen Rothwell wrote:
> After merging the driver-core tree, today's linux-next build (x86_64
> allmodconfig) produced this warning:
>
> drivers/net/dnet.c: In function 'dnet_mii_init':
> drivers/net/dnet.c:340: warning: passing argument 1 of 'platform_set_drvdata' from incompatible pointer type
> include/linux/platform_device.h:138: note: expected 'struct platform_device *' but argument is of type 'struct net_device *'

It's actually a bug in the driver. Thanks for reporting. I'll send the 
patch as a follow up.

Regards, Ilya.
