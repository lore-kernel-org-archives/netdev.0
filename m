From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Fri, 2 Dec 2016 16:38:15 +0100
Message-ID: <20161202153815.GK21887@lunn.ch>
References: <1480495831.3563.135.camel@infinera.com>
 <584054C4.1010809@ti.com>
 <20161201173100.GG21887@lunn.ch>
 <58409867.50001@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Roger Quadros <rogerq@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37687 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751367AbcLBPjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 10:39:25 -0500
Content-Disposition: inline
In-Reply-To: <58409867.50001@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2016 at 04:38:47PM -0500, Murali Karicheri wrote:
> Hi Andrew,
> On 12/01/2016 12:31 PM, Andrew Lunn wrote:
> > Hi Murali 
> > 
> >> 2. Switch mode where it implements a simple Ethernet switch. Currently
> >>    it doesn't have address learning capability, but in future it
> >>    can.
> > 
> > If it does not have address learning capabilities, does it act like a
> > plain old hub? What comes in one port goes out all others?
> 
> Thanks for the response!
> 
> Yes. It is a plain hub. it replicates frame to both ports. So need to
> run a bridge layer for address learning in software.

Hi Murali

It would be good if you start thinking about all the different
directions. It is not just host to port A and host to port B. What
about port A to Port B? Can it do that in hardware? 

> I think not. I see we have a non Linux implementation that does address
> learning in software using a hash table and look up MAC for each packet
> to see which port it needs to be sent to.

I think i need to read more about the switch. I'm starting to wonder
if it has enough intelligence to be usable. Switchdev is about pushing
configuration down into the switch. It does not however sound like
there is that much which is configurable in this switch.

      Andrew
