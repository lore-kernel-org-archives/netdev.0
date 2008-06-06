From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 04/39] mv643xx_eth: get rid of individual port config
	register bit defines
Date: Fri, 6 Jun 2008 03:52:42 -0700
Message-ID: <20080606105242.GA5499@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-5-git-send-email-buytenh@wantstofly.org> <20080605110734.GB1059@farnsworth.org> <20080606065839.GA5100@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:39463 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbYFFKww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:52:52 -0400
Content-Disposition: inline
In-Reply-To: <20080606065839.GA5100@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 06, 2008 at 08:58:39AM +0200, Lennert Buytenhek wrote:
> On Thu, Jun 05, 2008 at 04:07:34AM -0700, Dale Farnsworth wrote:
> > >  	config_reg = rdl(mp, PORT_CONFIG(mp->port_num));
> > >  	if (dev->flags & IFF_PROMISC)
> > > -		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
> > > +		config_reg |= 0x00000001;
> > 
> > Except for the stupid cast, I think the meaning was clearer with the
> > define.
> 
> Right, I got a bit carried away. :-)  How about this instead:

Looks good.

-Dale
