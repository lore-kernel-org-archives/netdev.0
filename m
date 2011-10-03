From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: fix build failure
Date: Mon, 03 Oct 2011 14:00:02 -0400 (EDT)
Message-ID: <20111003.140002.2213436684657121394.davem@davemloft.net>
References: <4E8534A9.3050002@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4E8534A9.3050002@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Fri, 30 Sep 2011 12:16:57 +0900

> The following commit removed some including headers:
>  "net: sh_eth: move the asm/sh_eth.h to include/linux/"
>  (commit id: d4fa0e35fdbd54acf791fa3793d6d17f7795f7ae)
> 
> Then, the build failure happened on the linux-next:
 ...
> This patch fixes the issue. This patch also get back include/kernel.h
> and linux/spinlock.h.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied, thanks.
