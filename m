From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast
 address to ALE table
Date: Sun, 21 Oct 2012 13:26:03 +0200
Message-ID: <20121021112603.GB6756@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-4-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59132 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab2JUL0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 07:26:13 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1479339wgb.1
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 04:26:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-4-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 04:15:15AM +0530, Mugunthan V N wrote:
> @@ -271,6 +273,30 @@ struct cpsw_priv {
>  			(func)((priv)->slaves + idx, ##arg);	\
>  	} while (0)
>  
> +static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +
> +	if (ndev->flags & IFF_PROMISC) {
> +		/* Enable promiscuous mode */
> +		dev_err(priv->dev, "Ignoring Promiscuous mode\n");
> +		return;

Why can't we support promiscuous mode here?

Thanks,
Richard
