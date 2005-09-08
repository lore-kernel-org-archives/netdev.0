From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 08 Sep 2005 16:42:35 +0200
Message-ID: <1126190554.4805.68.camel@tsc-6.cph.tpack.net>
References: <200509080125.j881PcL9015847@hera.kernel.org>
	 <431F9899.4060602@pobox.com>
	 <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>
	 <1126184700.4805.32.camel@tsc-6.cph.tpack.net>
	 <Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751373AbVIHOmi@vger.kernel.org>
To: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2005-09-08 at 15:35, Bogdan Costescu wrote:
> On Thu, 8 Sep 2005, Tommy Christensen wrote:
> 
> > The idea is to avoid an extra delay of 60 seconds before detecting 
> > link-up.
> 
> But you are adding the read to a function that is called repeatedly to 
> fix an event that happens only once at start-up !

Link state can change anytime, not just at start-up.  That's why
it's being repeatedly monitored ;-)

> If this read is really needed (I still doubt it...), can't it be 
> performed in vortex_up(), by possibly doubling the existing one there ?
> vortex_up() is executed only once at start-up, not every 60 seconds.

That won't solve the reported issue, unfortunately.

Besides, how long would you like to wait for network connectivity
after plugging in the cable?  It is now lowered from [60-120] to
[0-60] seconds.

Personally, I'd prefer the delay to be < 10 seconds.


-Tommy
