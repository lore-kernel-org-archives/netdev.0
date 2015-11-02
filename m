From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ravb: use pdev rather than ndev for error
 messages
Date: Mon, 02 Nov 2015 16:32:53 -0500 (EST)
Message-ID: <20151102.163253.1073537023536414920.davem@davemloft.net>
References: <1446428417-10895-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	magnus.damm@gmail.com
To: horms+renesas@verge.net.au
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1446428417-10895-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms+renesas@verge.net.au>
Date: Mon,  2 Nov 2015 10:40:17 +0900

> This corrects what appear to be typos, making the code consistent with
> itself, and allowing meaningful prefixes to be displayed with the errors in
> question.
> 
> Before:
>  (null): failed to initialize MDIO
>  (null): Cannot allocate desc base address table (size 176 bytes)
> 
> After:
> ravb e6800000.ethernet: failed to initialize MDIO
> ravb e6800000.ethernet: Cannot allocate desc base address table (size 176 bytes)
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Applied.
