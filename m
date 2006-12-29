From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Thu, 28 Dec 2006 21:05:46 -0800 (PST)
Message-ID: <20061228.210546.55150331.davem@davemloft.net>
References: <1165979533.11914.114.camel@localhost.localdomain>
	<20061212.200334.59657088.davem@davemloft.net>
	<1165982844.11914.125.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932647AbWL2FFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 00:05:47 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1165982844.11914.125.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 13 Dec 2006 15:07:24 +1100

> tg3 says
> 
> tg3: eth0: Link is up at 1000 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
> 
> but sungem says
> 
> eth0: Link is up at 1000 Mbps, full-duplex.
> eth0: Pause is disabled
> 
> Hrm... I suppose I need to dig more. No time to do that today though.

I was about to try and debug this, and noticed immediately that I
didn't recognize any of the code.

Could you look into this, you rewrote all of this stuff and this
looks like a regression added, because I know this pause stuff
used to work perfectly when I wrote the original GEM driver. :-)
