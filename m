From: walter harms <wharms@bfs.de>
Subject: Re: [patch 1/2] caif: remove unneeded variable from caif_net_open()
Date: Tue, 01 Jun 2010 09:27:02 +0200
Message-ID: <4C04B646.9080506@bfs.de>
References: <20100601070855.GD5483@bicker>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:1570 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754526Ab0FAH1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 03:27:25 -0400
In-Reply-To: <20100601070855.GD5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter schrieb:
> We don't use the "ser" variable so I've removed it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
> index 09257ca..f30a6a0 100644
> --- a/drivers/net/caif/caif_serial.c
> +++ b/drivers/net/caif/caif_serial.c
> @@ -410,8 +410,6 @@ static void caifdev_setup(struct net_device *dev)
>  
>  static int caif_net_open(struct net_device *dev)
>  {
> -	struct ser_device *ser;
> -	ser = netdev_priv(dev);
>  	netif_wake_queue(dev);
>  	return 0;
>  }


what makes caif_net_open() obsolet ?

re,
 wh

