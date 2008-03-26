From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [UML]: uml-net: don't set IFF_ALLMULTI in set_multicast_list
Date: Wed, 26 Mar 2008 02:10:21 -0400
Message-ID: <47E9E8CD.1060408@garzik.org>
References: <47E9E331.1010105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jdike@addtoit.com, user-mode-linux-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47823 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243AbYCZGK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 02:10:29 -0400
In-Reply-To: <47E9E331.1010105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static void uml_net_set_multicast_list(struct net_device *dev)
>  {
> -	if (dev->flags & IFF_PROMISC)
> -		return;
> -	else if (dev->mc_count)
> -		dev->flags |= IFF_ALLMULTI;
> -	else dev->flags &= ~IFF_ALLMULTI;
> +	return;
>  }



Might as well just delete the hook at that point...

	Jeff


