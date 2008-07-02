From: Patrick McHardy <kaber@trash.net>
Subject: Re: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Wed, 02 Jul 2008 14:55:14 +0200
Message-ID: <486B7AB2.9050104@trash.net>
References: <4869A251.108@cn.fujitsu.com> <4869A42A.2010009@cn.fujitsu.com> <4869FB80.8050107@trash.net> <486B3B32.3090702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36662 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbYGBMzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 08:55:16 -0400
In-Reply-To: <486B3B32.3090702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> v2->v3
>   Do some unwind work when error happen.
> 
> +static void ipmr_unreg_vif(struct net_device *dev)
> +{
> +	dev_close(dev);
> +	unregister_netdevice(dev);
> +	free_netdev(dev);
> +}

Same problems as the IPv6 version.

