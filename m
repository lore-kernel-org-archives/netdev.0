From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 14/39] mv643xx_eth: remove port serial status register
	bit defines
Date: Thu, 5 Jun 2008 04:41:44 -0700
Message-ID: <20080605114144.GN1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-15-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:44789 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152AbYFELlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:41:51 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-15-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:29PM +0200, Lennert Buytenhek wrote:
> All except one of the port serial status register bit defines are
> unused -- kill the unused ones.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   15 ++-------------
>  1 files changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 075ee2a..34bfdf6 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -94,6 +94,7 @@ static char mv643xx_driver_version[] = "1.0";
>  #define SDMA_CONFIG(p)			(0x041c + ((p) << 10))
>  #define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
>  #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
> +#define  TX_FIFO_EMPTY			0x00000400

Oops, an extra space sneaked in.

>  #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
>  #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
>  #define INT_CAUSE(p)			(0x0460 + ((p) << 10))

[snip]

Looks good otherwise.

-Dale
