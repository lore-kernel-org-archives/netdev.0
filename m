From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 problem on powerpc
Date: Mon, 4 Sep 2006 21:15:31 -0700
Message-ID: <20060904211531.307bbd7f@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	<1157354470.22705.26.camel@localhost.localdomain>
	<1157355748.22705.32.camel@localhost.localdomain>
	<20060904204148.6f9749b3@localhost.localdomain>
	<1157428072.22705.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17030 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965201AbWIEQb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 12:31:26 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157428072.22705.70.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 05 Sep 2006 13:47:52 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> 
> > It may not need any swapping, it is hard to tell what the hardware
> > will do without experimentation.
> 
> Yes... did you have a chance to test the vlan stuff on LE machines
> (x86) ? did it work with the BE swapping you were doing ? I've
> purposedly removed in my patches the hardware side swapping of the
> descriptors, as I explained, thus making the hardware react the same on
> ppc and x86. Thus we need the exact same swapping macros on both
> platforms).


Last time I checked it worked.  Private cable simulating VLAN
from other Linux card.

> I know pretty much nothing about vlan so I'm not too much about trying
> to check that right now :)
> 
> Also, there is still the hw checksum issue .... I need to verify what's
> up there, it might be a swapping problem as well... or not. Can you send
> me your latest patch set so I can work from there ?
> 
> Cheers,
> Ben
> 
