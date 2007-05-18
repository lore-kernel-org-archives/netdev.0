From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] netdevice ops
Date: Thu, 17 May 2007 22:58:33 -0700
Message-ID: <20070517225833.1b7e6acf@localhost>
References: <20070517210737.17d88401@localhost>
	<464D3175.8050007@pobox.com>
	<20070517.220529.115910791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:39689 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306AbXERF7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 01:59:31 -0400
In-Reply-To: <20070517.220529.115910791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 May 2007 22:05:29 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 18 May 2007 00:54:13 -0400
> 
> > Stephen Hemminger wrote:
> > > I want to take all the function pointers of 'struct net_device' and
> > > move them to 'struct net_device_ops'. This will save memory for the
> > > case of lots of devices, as well as reduce initialization code.
> > 
> > It will also add an additional deref to every operation, right?
> 
> Yes, it's certainly going to.  How much do we think that actually
> matters?

I would think a non-conditional deref would be easily pipelined.
If the net_device struct was more cache dense, it probably would
even out.
