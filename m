From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] Interface group: core (netlink) part
Date: Thu, 18 Oct 2007 12:22:13 +0200
Message-ID: <471733D5.4000500@trash.net>
References: <11927025171404-git-send-email-panther@balabit.hu> <1192702517840-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33681 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305AbXJRKWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:22:39 -0400
In-Reply-To: <1192702517840-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> @@ -846,6 +850,12 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		write_unlock_bh(&dev_base_lock);
>  	}
>  
> +	if (tb[IFLA_IFGROUP]) {
> +		write_lock_bh(&dev_base_lock);
> +		dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP]);
> +		write_unlock_bh(&dev_base_lock);
> +	}


So no notifications at all? Mhh .. I guess its OK for now, this stuff
needs to be fixed to notify once for all changes anyway.
