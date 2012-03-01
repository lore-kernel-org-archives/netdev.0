From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] davinci_emac: fixed setting MAC at init time
Date: Thu, 01 Mar 2012 16:28:37 -0500 (EST)
Message-ID: <20120301.162837.1843924175078247309.davem@davemloft.net>
References: <20120301084239.GA17146@altenpts-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, srk@ti.com,
	vinay.hegde@ti.com, cyril@ti.com, richard.cochran@omicron.at,
	Julia.Lawall@lip6.fr, s.hauer@pengutronix.de, joe@perches.com
To: b.van.den.berg.nl@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120301084239.GA17146@altenpts-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bas van den Berg <b.van.den.berg.nl@gmail.com>
Date: Thu, 1 Mar 2012 09:42:42 +0100

> Without this patch, the MAC number will show up as zero's until the interface
> is brought up for the first time. (eg. with ifconfig -a)
> 
> Signed-off-by: Bas van den Berg <b.van.den.berg.nl@gmail.com>

Well then the copy (which is also unnecessarily by hand using a loop
instead of a memcpy call) in emac_dev_open() is redundant and should
be removed when you make this change.
