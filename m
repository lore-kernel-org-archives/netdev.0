From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix EESIPR values for SH77{34|63}
Date: Fri, 06 Jan 2017 15:35:05 -0500 (EST)
Message-ID: <20170106.153505.2297570621984593459.davem@davemloft.net>
References: <1819012.0ROIJmx7mp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1819012.0ROIJmx7mp@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 04 Jan 2017 22:18:24 +0300

> As the SH77{34|63} manuals are freely available,  I've checked the EESIPR
> values written against the manuals, and they appeared to set the reserved
> bits 11-15 (which should be 0 on write). Fix those EESIPR values.
> 
> Fixes: 380af9e390ec ("net: sh_eth: CPU dependency code collect to "struct sh_eth_cpu_data"")
> Fixes: f5d12767c8fd ("sh_eth: get SH77{34|63} support out of #ifdef")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
