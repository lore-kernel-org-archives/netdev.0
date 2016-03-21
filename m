From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mdio-sun4i: oops in error handling in probe
Date: Mon, 21 Mar 2016 11:30:33 -0400 (EDT)
Message-ID: <20160321.113033.690236481925429149.davem@davemloft.net>
References: <20160321090231.GA31670@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, maxime.ripard@free-electrons.com,
	wens@csie.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160321090231.GA31670@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 21 Mar 2016 12:02:31 +0300

> We could end up dereferencing an error pointer when we call
> regulator_disable().
> 
> Fixes: 4bdcb1dd9feb ('net: Add MDIO bus driver for the Allwinner EMAC')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
