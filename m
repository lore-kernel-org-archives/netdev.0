From: Matthias Kaehlcke <matthias@kaehlcke.net>
Subject: Re: FEC driver: rcv is not +last
Date: Thu, 8 Apr 2010 16:53:24 +0200
Message-ID: <20100408145324.GH29538@darwin>
References: <20100408104033.GI3787@darwin>
 <20100408132033.GJ3688@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow3-v.mail.gandi.net ([217.70.178.89]:56148 "EHLO
	slow3-v.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758732Ab0DHOzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 10:55:41 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow3-v.mail.gandi.net (Postfix) with ESMTP id F1FDD399B9
	for <netdev@vger.kernel.org>; Thu,  8 Apr 2010 16:55:37 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20100408132033.GJ3688@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Thu, Apr 08, 2010 at 03:20:33PM +0200 Sascha Hauer ha dit:

> On Thu, Apr 08, 2010 at 12:40:33PM +0200, Matthias Kaehlcke wrote:
> > hi,
> > 
> > i have problems with the FEC on a i.MX25 3-Stack board. the kernel is
> > v2.6.34-rc2 plus the following patch:
> > http://patchwork.ozlabs.org/patch/41235/
> > 
> > the following traces are generated at boot time:
> > 
> > FEC Ethernet Driver
> > fec: PHY @ 0x1, ID 0x20005ce1 -- unknown PHY!
> > ...
> > eth0: config: auto-negotiation on, 100FDX, 100HDX, 10FDX, 10HDX.
> > ...
> > FEC ENET: rcv is not +last
> > FEC ENET: rcv is not +last
> > FEC ENET: rcv is not +last
> > FEC ENET: rcv is not +last
> > ...
> 
> No idea, I have never seen this message. Does the controller work
> besides these messages?

nope

> > the PHY of the board is a DP83840, which is not supported by the
> > driver. could this be the problem? i tried to make the kernel think
> > the DP83840 is a DP83848, which is supported, but the behaviour is the
> > same except the 'unknown PHY' warning.
> 
> This should be solved by the phylib patches recently posted for the fec
> driver.

thanks for the pointer!

i just applied the patch. it actually makes the 'unkown PHY' and even
the 'FEC ENET: rcv is not +last' messages disappear, but networking
still doesn't work

-- 
Matthias Kaehlcke
Embedded Linux Developer
Barcelona

  Control over the use of one's ideas really constitutes control over other
  people's lives; and it is usually used to make their lives more difficult.
                          (Richard Stallman)
                                                                 .''`.
    using free software / Debian GNU/Linux | http://debian.org  : :'  :
                                                                `. `'`
gpg --keyserver pgp.mit.edu --recv-keys 47D8E5D4                  `-
