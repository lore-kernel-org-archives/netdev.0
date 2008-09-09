From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: Extend smc911x to support LAN921x chips - differences?
Date: Tue, 9 Sep 2008 16:45:26 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0809091644250.7385@axis700.grange>
References: <Pine.LNX.4.64.0809091307160.6470@axis700.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55028 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752900AbYIIOhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 10:37:01 -0400
Received: from lyakh (helo=localhost)
	by axis700.grange with local-esmtp (Exim 4.63)
	(envelope-from <g.liakhovetski@gmx.de>)
	id 1Kd4T8-0002Gp-GW
	for netdev@vger.kernel.org; Tue, 09 Sep 2008 16:45:26 +0200
In-Reply-To: <Pine.LNX.4.64.0809091307160.6470@axis700.grange>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Sep 2008, Guennadi Liakhovetski wrote:

> Hi,
> 
> I have to support the LAN9215 chip from SMSC under Linux. Of course, there 
> is the manufacturer provided smsc911x driver, that supports both chip 
> families, but I would prefer to extend the mainline smc911x driver to also 
> support 921x. I have both datasheets, they are freely downloadable from 
> SMSC site, and I have both drivers, but they are absolutely different. To 
> make my decision and the work easier - maybe someone knows from the top of 
> their head, what the relevant differences between the chips are?
> 
> The vendor driver does not really differentiate between the chips. It does 
> read the chip version, and sets the "generation" variable, but then that 
> variable is only used once to rule out the oldest chips, which anyway are 
> not supported by smc911x. So I tried the in-kernel driver with only added 
> chip IDs added, it can access registers, read and write the MAC-address, 
> interrupts are generated too, but so far I see nothing on the wire, and 
> the PHY reports "link down".

No, I was wrong here, it does detect the link and performs 
autonegotiation, that doesn't seem to be the problem... Still, no clue 
what's wrong though:-(

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
