From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Minimizing TCP latency
Date: Tue, 30 Mar 2010 06:05:47 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1003300559040.28550@uplift.swm.pp.se>
References: <7c93bf1e1003281829h3ddba989w198df86ac9f2d27c@mail.gmail.com>  <7c93bf1e1003282024p75e70011j31577b42f29cc153@mail.gmail.com>  <1269840891.2256.28.camel@edumazet-laptop> <7c93bf1e1003291935k6c9060bah11e1138568ba6998@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Ben Hoyt <benhoyt@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:57949 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899Ab0C3EOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 00:14:11 -0400
In-Reply-To: <7c93bf1e1003291935k6c9060bah11e1138568ba6998@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010, Ben Hoyt wrote:

> We're currently seeing a round-trip time of about 40us between two
> Linux servers on our network (so presumably about 20us one way).
> Anything quicker than that would be nice, but we're hoping to get down
> to about half that.

Serialisation delay on GigE for a 512 byte packet is 4us if my 
calculations are correct, so if you have some equipment in between that 
means two serialisations either way, meaning on GigE just the 
serialisation delay is 16us RTT.

You'd probably be better off directly connection the two machines with 
10GE NIC, or at least buy equipment that'll do cut-through switching if 
you want to bring the delay down. I'm even surprised you got it down this 
low...

