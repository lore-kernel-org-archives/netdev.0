From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 08 Sep 2005 15:05:00 +0200
Message-ID: <1126184700.4805.32.camel@tsc-6.cph.tpack.net>
References: <200509080125.j881PcL9015847@hera.kernel.org>
	 <431F9899.4060602@pobox.com>
	 <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932512AbVIHNFL@vger.kernel.org>
To: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2005-09-08 at 13:58, Bogdan Costescu wrote:
> Can the original poster give an explanation ? I've enjoyed a rather 
> well functioning 3c59x driver for the past ~6 years without such 
> double reading. Plus:
> - this operation is I/O expensive
> - it is performed inside a region protected by a spinlock
> - it is performed often, every 60 seconds
> 
> Is there some specific hardware that exhibits a problem that is solved 
> by this double reading ?

Nothing critical. The idea is to avoid an extra delay of 60 seconds
before detecting link-up.

Please see http://bugzilla.kernel.org/show_bug.cgi?id=5025


-Tommy
