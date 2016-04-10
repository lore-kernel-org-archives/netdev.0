From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: re-enable-E-MAC interrupts in
 sh_eth_set_ringparam()
Date: Sat, 09 Apr 2016 21:27:25 -0400 (EDT)
Message-ID: <20160409.212725.649496142802966013.davem@davemloft.net>
References: <2542968.R3YjY2kHV4@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2542968.R3YjY2kHV4@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 10 Apr 2016 02:28:41 +0300

> The E-MAC interrupts are left disabled when the ring parameters are changed
> via 'ethtool'. In order to fix this, it's enough to call sh_eth_dev_init()
> with 'true' instead of 'false' for the second argument (which conveniently
> allows us to remove the following code re-enabling E-DMAC interrupts and
> reception).
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
