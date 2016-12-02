From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: renesas: ravb: unintialized return value
Date: Fri, 02 Dec 2016 14:00:30 -0500 (EST)
Message-ID: <20161202.140030.597013502556382328.davem@davemloft.net>
References: <20161201205744.GB10701@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, johan@kernel.org,
        ykaneko0929@gmail.com, kazuya.mizuguchi.ks@renesas.com,
        horms+renesas@verge.net.au, wsa+renesas@sang-engineering.com,
        andrew@lunn.ch, tremyfr@gmail.com,
        niklas.soderlund+renesas@ragnatech.se, arnd@arndb.de,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161201205744.GB10701@mwanda>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 1 Dec 2016 23:57:44 +0300

> We want to set the other "err" variable here so that we can return it
> later.  My version of GCC misses this issue but I caught it with a
> static checker.
> 
> Fixes: 9f70eb339f52 ("net: ethernet: renesas: ravb: fix fixed-link phydev leaks")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
