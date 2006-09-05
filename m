From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2 problem on powerpc
Date: Tue, 05 Sep 2006 13:47:52 +1000
Message-ID: <1157428072.22705.70.camel@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	 <1157354470.22705.26.camel@localhost.localdomain>
	 <1157355748.22705.32.camel@localhost.localdomain>
	 <20060904204148.6f9749b3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:29105 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S965133AbWIEDsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 23:48:02 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060904204148.6f9749b3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> It may not need any swapping, it is hard to tell what the hardware
> will do without experimentation.

Yes... did you have a chance to test the vlan stuff on LE machines
(x86) ? did it work with the BE swapping you were doing ? I've
purposedly removed in my patches the hardware side swapping of the
descriptors, as I explained, thus making the hardware react the same on
ppc and x86. Thus we need the exact same swapping macros on both
platforms).

I know pretty much nothing about vlan so I'm not too much about trying
to check that right now :)

Also, there is still the hw checksum issue .... I need to verify what's
up there, it might be a swapping problem as well... or not. Can you send
me your latest patch set so I can work from there ?

Cheers,
Ben

