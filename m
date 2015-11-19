From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: fix WARNING in __free_irq()
Date: Wed, 18 Nov 2015 22:04:17 -0500 (EST)
Message-ID: <20151118.220417.711975268777866760.davem@davemloft.net>
References: <4607844.sdhchmu5cM@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	kazuya.mizuguchi.ks@renesas.com, horms+renesas@verge.net.au
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4607844.sdhchmu5cM@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 19 Nov 2015 01:39:51 +0300

> When the R8A7795 support was  added to the driver, little attention was paid
> to the ravb_open() error path: free_irq()  for the EMAC interrupt was called
> uncoditionally, unlike request_irq(), and in  a wrong order as well...
> As a result, on the R-Car gen2 SoCs I started getting the following in case
> of a device  opening error:
 ...
> Fix up the free_irq() call order and add a new label on the error path.
> 
> Fixes: 22d4df8ff3a3 ("ravb: Add support for r8a7795 SoC")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
