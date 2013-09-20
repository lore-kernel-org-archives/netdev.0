From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] xen-netback: add a vif-is-connected
 flag
Date: Fri, 20 Sep 2013 14:40:29 -0400 (EDT)
Message-ID: <20130920.144029.56414879806328155.davem@davemloft.net>
References: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
	<1379685460-25032-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	david.vrabel@citrix.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab3ITSkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:40:31 -0400
In-Reply-To: <1379685460-25032-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 20 Sep 2013 14:57:39 +0100

> @@ -169,6 +169,7 @@ struct xenvif {
>  
>  	/* Miscellaneous private stuff. */
>  	struct net_device *dev;
> +	bool connected;
>  };
>  
>  static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
...
> +	vif->connected = 1;
 ...
> +	vif->connected = 0;

Please use 'true' and 'false' when assigning values to something
of "bool" type.

Also these look like bug fixes, and are thus more appropriately
targetted at 'net' and even potentially -stable as well.
