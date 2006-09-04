From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] DM9000 interrupt is hardware dependant
Date: Mon, 4 Sep 2006 23:40:02 +0100
Message-ID: <20060904224002.GB3623@home.fluff.org>
References: <200609042217.09004.linux@schindele.name> <20060904204646.GD3782@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: J?rgen Schindele <linux@schindele.name>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-84-9-201-122.bulldogdsl.com ([84.9.201.122]:11809 "EHLO
	aeryn.fluff.org.uk") by vger.kernel.org with ESMTP id S932192AbWIDWkR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 18:40:17 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060904204646.GD3782@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2006 at 10:46:46PM +0200, Lennert Buytenhek wrote:
> On Mon, Sep 04, 2006 at 10:17:08PM +0200, J?rgen Schindele wrote:
> 
> > i made a patch for an PXA270-evalboard with DM9000
> > ethernet contoller. The Interrupt can be high- or low-
> > active dependant of the wiring of the MDC-(57)pin.
> > 
> > Because of this hardware dependency you shoud be able
> > to configure this behaviour in "struct resource dm9000_resources[]"
> 
> Putting it in 'struct dm9000_plat_data' sounds like a much better
> idea to me...
> 
> Overloading the IRQ number in 'struct resource' is just ugly.

My view is that this would be useful to a number of drivers, and
is a good use of the resource flags for drivers which do not
currently have platform data.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
