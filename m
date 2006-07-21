From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 13:39:09 +0400
Message-ID: <20060721093909.GA14290@2ka.mipt.ru>
References: <20060721071009.GA5151@2ka.mipt.ru> <20060721.004713.71097915.davem@davemloft.net> <20060721090610.GF5151@2ka.mipt.ru> <20060721.021955.104040230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:9443 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750812AbWGUJjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 05:39:24 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060721.021955.104040230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 02:19:55AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 21 Jul 2006 13:06:11 +0400
> 
> > Receiving side, nor matter if it is socket or netchannel, will drop
> > packets (socket due to queue overfull, netchannels will not drop, but
> > will not ack (it's maximum queue len is 1mb)).
> > 
> > So both approaches behave _exactly_ the same.
> > Did I miss something?
> 
> Socket will not drop the packets on receive because sender will not
> violate the window which receiver advertises, therefore there is no
> reason to drop the packets.

How come?
sk_stream_rmem_schedule(), sk_rmem_alloc and friends...

-- 
	Evgeniy Polyakov
