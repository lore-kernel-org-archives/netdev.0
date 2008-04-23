From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Phy read timeout in ibm_new_emac driver
Date: Wed, 23 Apr 2008 15:18:48 +1000
Message-ID: <1208927928.9060.18.camel@pasglop>
References: <6a6049b80804160349q42120b4bs1c0db49ea5ad055d@mail.gmail.com>
	 <1208347791.6958.279.camel@pasglop>
	 <200804230706.32641.super.firetwister@gmail.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>
To: Markus Brunner <super.firetwister@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36276 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373AbYDWFS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 01:18:59 -0400
In-Reply-To: <200804230706.32641.super.firetwister@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-04-23 at 07:06 +0200, Markus Brunner wrote:
> On Wednesday 16 April 2008, Benjamin Herrenschmidt wrote:
> 
> > Somebody knows off hand what the standard says the timeout should be ?
> 
> Anyone?
> 
> I didn't find any documentation on the standard, but I had a look at other 
> drivers. 
> au1000_eth.c waits 20 ms (20 * 1ms) in mdio_read.
> bfin_mac.c waits 500 * 1us in mdio_poll. 
> In both functions the last delay before the timeout is useless, like in 
> new_emac. Not nice, but timeouts shouldn't occur anyway.
> 
> new emac probably doesn't wait long enough, but 20ms seems to be a bit too 
> long.

I just send Jeff a patch doubling the timeouts.

Cheers,
Ben.


