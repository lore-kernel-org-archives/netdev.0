From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:54:24 +0100
Message-ID: <1217501664.3454.151.camel@pmac.infradead.org>
References: <20080731092703.661994657@free-electrons.com>
	 <20080731093221.236840420@free-electrons.com>
	 <20080731104004.GN10471@solarflare.com>
	 <20080731.034904.190066778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, thomas.petazzoni@free-electrons.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	michael@free-electrons.com, mpm@selenic.com, jgarzik@pobox.com,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20080731.034904.190066778.davem@davemloft.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-07-31 at 03:49 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 31 Jul 2008 11:40:05 +0100
> 
> > You also need to conditionalise dev_disable_lro().
> 
> That can only be done once the CONFIG_ETHTOOL select statement
> is added for CONFIG_INET.
> 
> Which basically makes this CONFIG_ETHTOOL thing completely pointless.

Other potential approaches include not enabling LRO by default if 
!CONFIG_ETHTOOL. Or having the driver(s) which _do_ enable LRO by
default 'select ETHTOOL'.

-- 
dwmw2
