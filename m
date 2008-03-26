From: David Miller <davem@davemloft.net>
Subject: Re: [UML]: uml-net: don't set IFF_ALLMULTI in set_multicast_list
Date: Wed, 26 Mar 2008 00:16:47 -0700 (PDT)
Message-ID: <20080326.001647.97478240.davem@davemloft.net>
References: <47E9E331.1010105@trash.net>
	<47E9E8CD.1060408@garzik.org>
	<47E9E99F.5080003@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, jdike@addtoit.com,
	user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbYCZHQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 03:16:47 -0400
In-Reply-To: <47E9E99F.5080003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 26 Mar 2008 07:13:51 +0100

> Jeff Garzik wrote:
> >>  static void uml_net_set_multicast_list(struct net_device *dev)
> >>  {
> >> -    if (dev->flags & IFF_PROMISC)
> >> -        return;
> >> -    else if (dev->mc_count)
> >> -        dev->flags |= IFF_ALLMULTI;
> >> -    else dev->flags &= ~IFF_ALLMULTI;
> >> +    return;
> >>  }
> > 
> > 
> > 
> > Might as well just delete the hook at that point...
> 
> 
> I kept it so SIOCADDMULTI/SIOCDELMULTI ioctls continue to
> work on UML devices. I don't know if any userspace applications
> check for errors when using these ioctls, this way nothing
> can break.

Good idea, patch applied to net-2.6, thanks!
