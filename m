From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 07/24] can: Remove unnecessary OOM logging messages
Date: Wed, 31 Aug 2011 19:11:14 +0200
Message-ID: <4E5E6B32.8040902@hartkopp.net>
References: <cover.1314650069.git.joe@perches.com> <d2773db0709a09bfe6d43a28ba1323c5d3f9a76b.1314650069.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:32115 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736Ab1HaRLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 13:11:21 -0400
In-Reply-To: <d2773db0709a09bfe6d43a28ba1323c5d3f9a76b.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.08.2011 23:17, Joe Perches wrote:

> Removing unnecessary messages saves code and text.
> 
> Site specific OOM messages are duplications of a generic MM
> out of memory message and aren't really useful, so just
> delete them.
> 
> Signed-off-by: Joe Perches <joe@perches.com>


Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Tnx Joe.

> ---
>  net/can/af_can.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index b9efa94..11300be 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -770,11 +770,9 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
>  
>  		/* create new dev_rcv_lists for this device */
>  		d = kzalloc(sizeof(*d), GFP_KERNEL);
> -		if (!d) {
> -			printk(KERN_ERR
> -			       "can: allocation of receive list failed\n");
> +		if (!d)
>  			return NOTIFY_DONE;
> -		}
> +
>  		BUG_ON(dev->ml_priv);
>  		dev->ml_priv = d;
>  
