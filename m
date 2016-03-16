From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: do not call netif_start_queue() from
 sh_eth_dev_init()
Date: Wed, 16 Mar 2016 19:25:21 -0400 (EDT)
Message-ID: <20160316.192521.1973203555087281934.davem@davemloft.net>
References: <2129265.GisCEHHzPr@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2129265.GisCEHHzPr@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 14 Mar 2016 01:09:53 +0300

> Iff  sh_eth_phy_start() call fails in sh_eth_open(), the netif_start_queue()
> call done by sh_eth_dev_init()  is not undone.  In order to deal with that,
> stop calling netif_start_queue()  from there, so that it can be called only
> when the device is fully opened and sh_eth_dev_init() only deals with the
> hardware initialization, symmetrically to sh_eth_dev_exit()...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
