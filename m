From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ks8695net: Use default implementation of
 ethtool_ops::get_link
Date: Thu, 13 Jan 2011 21:51:09 -0800 (PST)
Message-ID: <20110113.215109.247138667.davem@davemloft.net>
References: <1294941014.3946.46.camel@bwh-desktop>
	<1294941171.3946.49.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: figo1802@gmail.com, zealcook@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753551Ab1ANFug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:50:36 -0500
In-Reply-To: <1294941171.3946.49.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 13 Jan 2011 17:52:51 +0000

> This is completely untested as I don't have an ARM build environment.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
 ...
> -/**
>   *	ks8695_wan_get_pause - Retrieve network pause/flow-control
> advertising
>   *	@ndev: The device to retrieve settings from
>   *	@param: The structure to fill out with the information

Line-wrap damage from your mail client.

> @@ -1058,7 +1044,7 @@ static const struct ethtool_ops
> ks8695_wan_ethtool_ops = {
>  	.get_settings	= ks8695_wan_get_settings,

Same here.

I fixed this up and applied your patch.
