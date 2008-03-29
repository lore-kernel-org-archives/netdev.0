From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] Blackfin EMAC Driver: delete unused variables to
 fixup gcc warnings
Date: Fri, 28 Mar 2008 21:54:13 -0400
Message-ID: <47EDA145.5080907@garzik.org>
References: <> <1206580918-24720-3-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Frysinger <vapier.adi@gmail.com>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59649 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022AbYC2ByP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:54:15 -0400
In-Reply-To: <1206580918-24720-3-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
> 
> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  drivers/net/bfin_mac.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index c993a32..26b2dd5 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -575,7 +575,6 @@ adjust_head:
>  static int bf537mac_hard_start_xmit(struct sk_buff *skb,
>  				struct net_device *dev)
>  {
> -	struct bf537mac_local *lp = netdev_priv(dev);
>  	unsigned int data;
>  
>  	current_tx_ptr->skb = skb;
> @@ -634,7 +633,6 @@ out:
>  static void bf537mac_rx(struct net_device *dev)
>  {
>  	struct sk_buff *skb, *new_skb;
> -	struct bf537mac_local *lp = netdev_priv(dev);
>  	unsigned short len;

applied



