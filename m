From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm : fix
 /sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Tue, 16 Feb 2010 22:16:51 -0800 (PST)
Message-ID: <20100216.221651.189702430.davem@davemloft.net>
References: <20100214175136.GA15891@frolo.macqel>
	<201002142134.o1ELYehH019725@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phdm@macqel.be, netdev@vger.kernel.org
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54556
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083Ab0BQGQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 01:16:38 -0500
In-Reply-To: <201002142134.o1ELYehH019725@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Sun, 14 Feb 2010 16:34:40 -0500

> as i said before there is carrier or there is not.  if the driver
> doesnt support checking/knowing the carrier status it should simply
> say 'yes i have carrier'.

I agree %100 and this is how we handle similar situations
for other networking device types.
