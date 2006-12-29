From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Sat, 30 Dec 2006 08:36:07 +1100
Message-ID: <1167428167.23340.114.camel@localhost.localdomain>
References: <1165979533.11914.114.camel@localhost.localdomain>
	 <20061212.200334.59657088.davem@davemloft.net>
	 <1165982844.11914.125.camel@localhost.localdomain>
	 <20061228.210546.55150331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54024 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965090AbWL2Vgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 16:36:32 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061228.210546.55150331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-28 at 21:05 -0800, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Wed, 13 Dec 2006 15:07:24 +1100
> 
> > tg3 says
> > 
> > tg3: eth0: Link is up at 1000 Mbps, full duplex.
> > tg3: eth0: Flow control is on for TX and on for RX.
> > 
> > but sungem says
> > 
> > eth0: Link is up at 1000 Mbps, full-duplex.
> > eth0: Pause is disabled
> > 
> > Hrm... I suppose I need to dig more. No time to do that today though.
> 
> I was about to try and debug this, and noticed immediately that I
> didn't recognize any of the code.
> 
> Could you look into this, you rewrote all of this stuff and this
> looks like a regression added, because I know this pause stuff
> used to work perfectly when I wrote the original GEM driver. :-)

Heh, it's very possible it's a regression I added indeed. I'll try to
have a look next week. Do you know of anybody who can verify on non-mii
hardware or is pause irrelevant there ?

Ben.


