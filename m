From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH/RFC 2/3] ethernet: add a PHY reset GPIO DT binding to
 sh_eth
Date: Fri, 25 Jan 2013 11:21:37 -0700
Message-ID: <20130125182137.GB7393@obsidianresearch.com>
References: <1359043653-11374-1-git-send-email-g.liakhovetski@gmx.de>
 <1359043653-11374-3-git-send-email-g.liakhovetski@gmx.de>
 <7921225.sfO3PIeLVS@avalon>
 <Pine.LNX.4.64.1301251127460.17518@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	linux-sh@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	linux-arm-kernel@lists.infradead.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:50890 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932108Ab3AYSVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 13:21:41 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1301251127460.17518@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 25, 2013 at 11:34:55AM +0100, Guennadi Liakhovetski wrote:

> > Is there no need to reset the phy at runtime ?
> 
> No idea, I'm not developing the driver, I'm just porting one specific 
> feature from one API to another with no functional changes (apart from 
> postponing setting the GPIO).

Generally Linux relies on resetting the phy via the inband MDIO method,
which is what Linux does. It is pretty much never required to reset
via the hard pin - but you do need to generate a robust reset edge on
the reset pin once after power up.

Jason
