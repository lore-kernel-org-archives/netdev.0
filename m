From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH] drivers/net/ehea - remove unnecessary memset after kzalloc
Date: Tue, 20 May 2008 14:53:57 +0100
Message-ID: <200805201553.58431.ossthema@de.ibm.com>
References: <20080512213601.626C91C0008F@mwinf2103.orange.fr> <1210628297.14967.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	linux <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Christophe Jaillet <christophe.jaillet@wanadoo.fr>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:65302 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932483AbYETNzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 09:55:02 -0400
In-Reply-To: <1210628297.14967.16.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 12 May 2008 23:38, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> ---
> 
>  drivers/net/ehea/ehea_main.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index f9bc21c..fd4be0d 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -2207,18 +2207,16 @@ static void ehea_vlan_rx_register(struct net_device *dev,
>  	port->vgrp = grp;
> 
>  	cb1 = kzalloc(PAGE_SIZE, GFP_KERNEL);
>  	if (!cb1) {
>  		ehea_error("no mem for cb1");
>  		goto out;
>  	}
> 
> -	memset(cb1->vlan_filter, 0, sizeof(cb1->vlan_filter));
> -
>  	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
>  				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
>  	if (hret != H_SUCCESS)
>  		ehea_error("modify_ehea_port failed");
> 
>  	kfree(cb1);
>  out:
>  	return;
> 
The patch looks good. 

Acked-by: Jan-Bernd Themann <themann@de.ibm.com>

Thanks,
Jan-Bernd
