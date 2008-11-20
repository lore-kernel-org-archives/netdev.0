From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Fix dependency for SFC_MTD
Date: Thu, 20 Nov 2008 04:17:53 -0800 (PST)
Message-ID: <20081120.041753.264904694.davem@davemloft.net>
References: <20081119204850.GF8240@solarflare.com>
	<20081119205353.GG8240@solarflare.com>
	<4924872E.5070102@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, dwmw2@infradead.org,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4924872E.5070102@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 19 Nov 2008 13:37:50 -0800

> Ben Hutchings wrote:
> > Randy Dunlap found that SFC_MTD was selected when sfc was built-in and
> > the MTD core was a module.  Don't allow that combination.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> I realized that this problem came up because SFC_MTD is a boolean
> that depends on tristates, so the boolean is set (=y) when
> SFC=y or SFC=m.  Thus extra handling for it is needed,
> like Ben did here.

Applied, thanks everyone.
