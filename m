From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4 v4] Marvell phy: check link status in case of fiber
 link.
Date: Fri, 15 Jul 2016 15:58:20 +0200
Message-ID: <20160715135820.GR6667@lunn.ch>
References: <9e170b8a-cfd7-42ef-0beb-29161d283b00@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43295 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915AbcGON6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 09:58:22 -0400
Content-Disposition: inline
In-Reply-To: <9e170b8a-cfd7-42ef-0beb-29161d283b00@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2016 at 12:11:30PM +0200, Charles-Antoine Couret wrote:
> Hello,
> 
> It's my 4rd patch set for this feature.
> Thanks to comment my work. :)

Hi Charles-Antoine

The above comment should go into patch 0/4. git format-patch --cover
will generate you a template cover note.

> +#define ADVERTISE_PAUSE_FIBER		0x180
> +#define ADVERTISE_PAUSE_ASYM_FIBER	0x100
> +
> +#define REGISTER_LINK_STATUS	0x400
> +#define NB_FIBER_STATS	1

This last define goes into the next patch.

Otherwise, this is looking good.

	   Andrew
