From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove useless if check from
 register_netdevice()
Date: Wed, 12 Feb 2014 09:46:11 -0500 (EST)
Message-ID: <20140212.094611.946835062678856302.davem@davemloft.net>
References: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbaBLOqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 09:46:12 -0500
In-Reply-To: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 12 Feb 2014 11:45:52 +0400

> @@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
>  	if (dev->netdev_ops->ndo_init) {
>  		ret = dev->netdev_ops->ndo_init(dev);
>  		if (ret) {
> -			if (ret > 0)
> -				ret = -EIO;
> +            ret = -EIO;
>  			goto out;
>  		}

Like your other patch you are not formatting this code properly at all.

If you cannot insert the correct TAB and space characters necessary
to indent the code properly, have something help you do it, such as
emacs's C-mode in "linux" mode.
