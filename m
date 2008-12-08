From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: cleanup for net/core/dev.c
Date: Mon, 8 Dec 2008 18:32:18 +0300
Message-ID: <20081208153218.GA3788@x200.localdomain>
References: <20081208145214.GA6830@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jianjun Kong <jianjun@zeuux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:52703 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbYLHP14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 10:27:56 -0500
Received: by ey-out-2122.google.com with SMTP id 6so483085eyi.37
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 07:27:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081208145214.GA6830@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 08, 2008 at 10:52:14PM +0800, Jianjun Kong wrote:

> -	if (sizeof_priv) {
> -		dev->priv = ((char *)dev +
> -			     ((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
> -			      & ~NETDEV_ALIGN_CONST));
> -	}
> +	if (sizeof_priv)
> +		dev->priv = netdev_priv(dev);

If I understood all of this correctly, ->priv is going away, so there is
no point in changing it's initialisation.
