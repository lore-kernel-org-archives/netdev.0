From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: RX problem in ibm_newemac driver
Date: Wed, 11 Mar 2009 09:57:12 +1100
Message-ID: <1236725832.7086.21.camel@pasglop>
References: <49B6C4A2.8060302@embedded-sol.com>
	 <1236718202.7086.10.camel@pasglop>  <49B6E658.4010900@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50944 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755589AbZCJW5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 18:57:21 -0400
In-Reply-To: <49B6E658.4010900@embedded-sol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-03-11 at 00:14 +0200, Felix Radensky wrote:
> Yes, seems logical. U-boot has code to enable and disable loopback clock
> for 440SPE, 440EPX,440GRX,405EX, 460EX and 460GT.
> 
> I can test patches on my board. Alternatively, I can try something myself
> if you can provide some guidance. I guess you are referring to the code 
> using
> EMAC_FTR_440GX_PHY_CLK_FIX and EMAC_FTR_440EP_PHY_CLK_FIX.

It would be nice if you could try something as I don't have anything to
test here.

And yes, it's probably one of those 2 fixes that need to be extended.

I'll have a look later today if I can find the 405EXr user manual and
give you more precise guidance.

Cheers,
Ben.


