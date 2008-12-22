From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qlge: ql_adapter_down() typo
Date: Mon, 22 Dec 2008 08:55:07 -0800
Message-ID: <20081222165507.GA32049@susedev.qlogic.org>
References: <494E609E.3090808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12809 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbYLVQzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 11:55:08 -0500
Content-Disposition: inline
In-Reply-To: <494E609E.3090808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Roel

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

On Sun, Dec 21, 2008 at 07:28:30AM -0800, Roel Kluin wrote:
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> index b83a9c9..4a66aa5 100644
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -3156,7 +3156,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
>  	 * a workqueue only if it's a single interrupt
>  	 * environment (MSI/Legacy).
>  	 */
> -	for (i = 1; i > qdev->rx_ring_count; i++) {
> +	for (i = 1; i < qdev->rx_ring_count; i++) {
>  		rx_ring = &qdev->rx_ring[i];
>  		/* Only the RSS rings use NAPI on multi irq
>  		 * environment.  Outbound completion processing
