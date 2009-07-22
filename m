From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH] 3c589_cs: re-initialize the multicast in the
 tc589_reset
Date: Wed, 22 Jul 2009 21:23:38 +0900
Message-ID: <20090722212338.a431b86c.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090720080812.49633622.ken_kawasaki@spring.nifty.jp>
	<20090720.082906.101507247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg500.nifty.com ([202.248.238.80]:63787 "EHLO
	userg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbZGVMX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 08:23:57 -0400
In-Reply-To: <20090720.082906.101507247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jul 2009 08:29:06 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:


> > 3c589_cs: 
> > re-initialize the multicast in the tc589_reset,
> > and spin_lock the set_multicast_list function.  
> > 
> > Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
> 
> Applied, but you really need to fix your coding style.
> 
> I know perhaps you were trying to be consistent with the
> rest of this driver, but when adding completely new code
> the conventions of the rest of the kernel ought to be
> followed, for example:
> 
> > +static void set_multicast_list(struct net_device *dev)
> > +{
> > +    struct el3_private *priv = netdev_priv(dev);
> > +    unsigned long flags;
> > +
> > +    spin_lock_irqsave(&priv->lock, flags);    
> > +    set_rx_mode(dev);
> > +    spin_unlock_irqrestore(&priv->lock, flags);    
> > +}
> 
> One tab should begin each statement in this function, and
> spin_lock and spin_unlock lines had unnecessary trailing
> whitespace.
> 
> I fixed all of this up when applying your patch, but I
> absolutely will not do so next time.

OK.
Thanks!
