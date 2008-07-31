From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 03:57:08 -0700 (PDT)
Message-ID: <20080731.035708.149435626.davem@davemloft.net>
References: <20080731104004.GN10471@solarflare.com>
	<20080731.034904.190066778.davem@davemloft.net>
	<1217501664.3454.151.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, thomas.petazzoni@free-electrons.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, mpm@selenic.com, jgarzik@pobox.com,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: dwmw2@infradead.org
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <1217501664.3454.151.camel@pmac.infradead.org>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 31 Jul 2008 11:54:24 +0100

> Other potential approaches include not enabling LRO by default if 
> !CONFIG_ETHTOOL. Or having the driver(s) which _do_ enable LRO by
> default 'select ETHTOOL'.

It is possible for us to generically enable LRO for every device,
since it is a software algorithm.  And likely we will do something
like this in the not too distant future.
