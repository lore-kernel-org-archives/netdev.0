From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH?] atl1e: WAKE_MCAST 2x. 1st WAKE_UCAST?
Date: Thu, 14 Aug 2008 04:44:46 -0400
Message-ID: <48A3F07E.8000808@garzik.org>
References: <489B21CA.7010508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jie.yang@atheros.com, jgarzik@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: roel kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36254 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922AbYHNIpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:45:01 -0400
In-Reply-To: <489B21CA.7010508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roel kluin wrote:
> untested, is it right?
> ---
> WAKE_MCAST bit tested twice, test WAKE_UCAST first.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
> index cdc3b85..619c658 100644
> --- a/drivers/net/atl1e/atl1e_ethtool.c
> +++ b/drivers/net/atl1e/atl1e_ethtool.c
> @@ -355,7 +355,7 @@ static int atl1e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
>  	struct atl1e_adapter *adapter = netdev_priv(netdev);
>  
>  	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
> -			    WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))
> +			    WAKE_UCAST | WAKE_MCAST | WAKE_BCAST))
>  		return -EOPNOTSUPP;
>  	/* these settings will always override what we currently have */

applied


