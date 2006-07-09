From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Sun, 09 Jul 2006 22:05:43 +0200
Message-ID: <m3irm6v90o.fsf@defiant.localdomain>
References: <44AE2FCC.6020207@trash.net>
	<20060707143314.67bf07ff@dxpl.pdx.osdl.net>
	<200607091049.31628.stefan@loplof.de>
	<20060709.114827.63031023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan@loplof.de, shemminger@osdl.org, kaber@trash.net,
	greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:29836 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1161095AbWGIUFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 16:05:45 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060709.114827.63031023.davem@davemloft.net> (David Miller's message of "Sun, 09 Jul 2006 11:48:27 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> > Not really. The flag code last major change was to do the dormant
>> > stuff that HDLC wanted.
>> 
>> ... and where the maintainer doesn't seem to care to use it now that the 
>> infrastructure is there. Sigh.

This is very different from what I proposed and doesn't fit very well.
We've been discussing this to death.

> Yes, this is very unfortunate.  They made the loudest noise about
> wanting the change, yet they aren't even responsible enough to submit
> the HDLC patches necessary to make use of it.  This was apparently
> needed to fix HDLC, so where's the followup?

I'm still thinking how to use it safely. Should it be implemented
sanely, things would be different.

> This is why the HDLC "maintainers" shouldn't be surprised if we flat
> out ignore them the next time they complain about anything.

You are correct - some time ago, I was really surprised. Now, especially
having received that private mail from you - the situation is obvious.

I'm a single developer BTW.
-- 
Krzysztof Halasa
