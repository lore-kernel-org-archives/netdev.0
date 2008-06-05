From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 10/39] mv643xx_eth: clarify irq masking and unmasking
Date: Thu, 5 Jun 2008 04:44:06 -0700
Message-ID: <20080605114406.GA3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-11-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:44830 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492AbYFELoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:44:14 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-11-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:25PM +0200, Lennert Buytenhek wrote:
> Replace the nondescriptive names ETH_INT_UNMASK_ALL and
> ETH_INT_UNMASK_ALL_EXT by names of the actual fields being masked
> and unmasked in the various writes to the interrupt mask registers.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   61 +++++++++++++++++---------------------------
>  1 files changed, 24 insertions(+), 37 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index bdb03f3..ffdd3fc 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -97,7 +97,14 @@ static char mv643xx_driver_version[] = "1.0";
>  #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
>  #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
>  #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
> +#define  INT_RX				0x00000804
> +#define  INT_EXT			0x00000002
>  #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
> +#define  INT_EXT_LINK			0x00100000
> +#define  INT_EXT_PHY			0x00010000
> +#define  INT_EXT_TX_ERROR_0		0x00000100
> +#define  INT_EXT_TX_0			0x00000001
> +#define  INT_EXT_TX			0x00000101

Oops, I missed this the first time.  You have an extra space in each
of the above added defines.

>  #define INT_MASK(p)			(0x0468 + ((p) << 10))
>  #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
>  #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))

[snip]

-Dale
