From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [PATCH] atm : fix
	/sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Wed, 17 Feb 2010 12:35:29 +0100
Message-ID: <20100217113529.GA18818@frolo.macqel>
References: <20100214175136.GA15891@frolo.macqel> <201002142134.o1ELYehH019725@thirdoffive.cmf.nrl.navy.mil> <20100216.221651.189702430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:44637 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755310Ab0BQLfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:35:34 -0500
Content-Disposition: inline
In-Reply-To: <20100216.221651.189702430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chas, David,

On Tue, Feb 16, 2010 at 10:16:51PM -0800, David Miller wrote:
> From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
> Date: Sun, 14 Feb 2010 16:34:40 -0500
> 
> > as i said before there is carrier or there is not.  if the driver
> > doesnt support checking/knowing the carrier status it should simply
> > say 'yes i have carrier'.
> 
> I agree %100 and this is how we handle similar situations
> for other networking device types.

I also agree 100% with that : the low-level driver must do that, not the
generic class driver.  Here cxacru is punished because other atm drivers
forget to set signal = ATM_PHY_SIG_FOUND.

Philippe
