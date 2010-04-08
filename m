From: Matthias Kaehlcke <matthias@kaehlcke.net>
Subject: Re: FEC driver: rcv is not +last
Date: Thu, 8 Apr 2010 18:04:46 +0200
Message-ID: <20100408160446.GL29538@darwin>
References: <20100408104033.GI3787@darwin>
 <20100408132033.GJ3688@pengutronix.de>
 <20100408145324.GH29538@darwin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:39379 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954Ab0DHQG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 12:06:26 -0400
Content-Disposition: inline
In-Reply-To: <20100408145324.GH29538@darwin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Thu, Apr 08, 2010 at 04:53:24PM +0200 Matthias Kaehlcke ha dit:

> El Thu, Apr 08, 2010 at 03:20:33PM +0200 Sascha Hauer ha dit:
> 
> > On Thu, Apr 08, 2010 at 12:40:33PM +0200, Matthias Kaehlcke wrote:
> > > hi,
> > > 
> > > i have problems with the FEC on a i.MX25 3-Stack board. the kernel is
> > > v2.6.34-rc2 plus the following patch:
> > > http://patchwork.ozlabs.org/patch/41235/
> > > 
> > > the following traces are generated at boot time:
> > > 
> > > FEC Ethernet Driver
> > > fec: PHY @ 0x1, ID 0x20005ce1 -- unknown PHY!
> > > ...
> > > eth0: config: auto-negotiation on, 100FDX, 100HDX, 10FDX, 10HDX.
> > > ...
> > > FEC ENET: rcv is not +last
> > > FEC ENET: rcv is not +last
> > > FEC ENET: rcv is not +last
> > > FEC ENET: rcv is not +last
> > > ...
> > 
> > No idea, I have never seen this message. Does the controller work
> > besides these messages?
> 
> nope
> 
> > > the PHY of the board is a DP83840, which is not supported by the
> > > driver. could this be the problem? i tried to make the kernel think
> > > the DP83840 is a DP83848, which is supported, but the behaviour is the
> > > same except the 'unknown PHY' warning.
> > 
> > This should be solved by the phylib patches recently posted for the fec
> > driver.
> 
> thanks for the pointer!
> 
> i just applied the patch. it actually makes the 'unkown PHY' and even
> the 'FEC ENET: rcv is not +last' messages disappear, but networking
> still doesn't work

i just received a mail from our distributor:

the PDK board they gave us for evaluation is a preliminary version,
with a slightly different hardware than the official one. they suppose
that's the reason of our problem

sorry for the noise

-- 
Matthias Kaehlcke
Embedded Linux Developer
Barcelona

      Debugging is like alien abduction. Large blocks of time disappear,
                    for which you have no explanation
                                                                 .''`.
    using free software / Debian GNU/Linux | http://debian.org  : :'  :
                                                                `. `'`
gpg --keyserver pgp.mit.edu --recv-keys 47D8E5D4                  `-
