From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: fix accounting of packet drops vs
 errors
Date: Thu, 09 Jul 2015 21:10:43 -0700 (PDT)
Message-ID: <20150709.211043.898973722945548914.davem@davemloft.net>
References: <089e0122a88432eb63051a678bba@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbbGJEKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 00:10:43 -0400
In-Reply-To: <089e0122a88432eb63051a678bba@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Thu, 09 Jul 2015 01:55:02 +0000

> bcmgenet driver needs to separate packet drops from packet errors.
> 
> When the driver has to drop a *good* packet, due to lack of buffers or
> replacement skbs, increment only dev->stats.[rx|tx]_dropped.
> 
> When the driver encounters a bad Rx packet or Tx error, increment only
> dev->stats.[rx|tx]_errors + relevant detailed error counter.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index b43b2cb..64c1e9d 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1230,7 +1230,6 @@ static struct sk_buff
> *bcmgenet_put_tx_csum(struct net_device *dev,

This is severely corrupted by your email client.

Please fix this, email a test patch to yourself, and only resubmit
this patch to the mailing list if you can successfully apply the
patch you receive in that test email.

Thanks.
