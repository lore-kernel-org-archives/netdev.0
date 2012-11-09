From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: query on dynamic switching between Ethernet ports
Date: Fri, 9 Nov 2012 15:36:43 +0000
Message-ID: <1352475403.3159.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAJ3bTp7zXVB5NSj+8J8bR+pvg7mgJ7UjxqhubGxEYmdbpfEVxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16588 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750922Ab2KIPgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:36:47 -0500
In-Reply-To: <CAJ3bTp7zXVB5NSj+8J8bR+pvg7mgJ7UjxqhubGxEYmdbpfEVxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 20:02 +0530, Rayagond K wrote:
> Hi All,
> 
> I am implementing handling of dynamic switching between Ethernet ports
> (1GMbps to 100Mbps mode) using PHY layer, I referred various driver in
> LXR and doc and I am able to understand the PHY layer and implement in
> my driver.
> 
> For now I am able to do following in my driver now,
> 
> 1. Advertising all the capabilities like FULL duplex, half duplex,
> pause frames, MII/GMII etc while registering with PHY layer.
> 2. Able to detect the link up and link down.
> 3. Able do the auto-negotiation with remote end link partner and
> program my MAC accordingly.
> 4. Able to establish the link by connecting and disconnecting the
> cable many times.
> 
> But I am facing one problem ie my driver is not able to establish the
> link when I load the driver first time and connected to 1G port. If I
> toggle the port connection between MII(10/100Mbps) and GMII(1Gbps) for
> two/three times and connect it back to GMII ports then driver works
> fine and it establish the link.

Is the driver resetting everything it needs to when loaded?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
