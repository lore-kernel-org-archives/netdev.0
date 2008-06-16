From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Mon, 16 Jun 2008 16:40:32 -0700 (PDT)
Message-ID: <20080616.164032.197767785.davem@davemloft.net>
References: <1212589713.13164.75.camel@localhost.localdomain>
	<1213264875.29292.17.camel@localhost.localdomain>
	<48538CC8.9020706@cdi.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org, kaber@trash.net
To: devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754611AbYFPXkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 19:40:32 -0400
In-Reply-To: <48538CC8.9020706@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>
Date: Sat, 14 Jun 2008 11:18:00 +0200

> > I have now tested/deployed the patches on two production servers.
> > 
> >  Conclusion is: It should be safe to apply these patches.
> > 
> > See full report here:
> > http://people.netfilter.org/hawk/patches/htb_nohyst/production_test_results.html
> > 
> > We saw an increased number of interrupts on the test system, when
> > enabling/disabling htb_hysteresis.
> > 
> >  This didn't show up on the production system.
> > 
> > I believe that the increased intr (on test system) is an artifact of the
> > TCP download got less bursty and more smooth.
> 
> Which reminds me again, maybe after some time with hysteresis=off we 
> could remove it altogether...
> 
> Sorry for the delay, I got some flu or what. On my smaller dualcore 
> system there is also no noticeable (performance) impact.
> 
> I ACK Jesper's patches, thanks for the work and real-world testing!

I've applied Jesper's work to net-2.6, as it is primarily a bug
fix of sorts and safe because a backwards compatible knob is
provided just in case it does cause problems for people.

Thanks everyone!
