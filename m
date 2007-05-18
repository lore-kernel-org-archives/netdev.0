From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netdevice ops
Date: Thu, 17 May 2007 22:05:29 -0700 (PDT)
Message-ID: <20070517.220529.115910791.davem@davemloft.net>
References: <20070517210737.17d88401@localhost>
	<464D3175.8050007@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754836AbXERFF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 01:05:27 -0400
In-Reply-To: <464D3175.8050007@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 18 May 2007 00:54:13 -0400

> Stephen Hemminger wrote:
> > I want to take all the function pointers of 'struct net_device' and
> > move them to 'struct net_device_ops'. This will save memory for the
> > case of lots of devices, as well as reduce initialization code.
> 
> It will also add an additional deref to every operation, right?

Yes, it's certainly going to.  How much do we think that actually
matters?
