From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Tue, 17 Jun 2008 04:00:19 +0300
Message-ID: <20080617005938.M55099@visp.net.lb>
References: <1212589713.13164.75.camel@localhost.localdomain> <1213264875.29292.17.camel@localhost.localdomain> <48538CC8.9020706@cdi.cz> <20080616.164032.197767785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: jdb@comx.dk, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:54275 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbYFQBAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 21:00:25 -0400
In-Reply-To: <20080616.164032.197767785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 16:40:32 -0700 (PDT), David Miller wrote
> From: Martin Devera <devik@cdi.cz>
> Date: Sat, 14 Jun 2008 11:18:00 +0200
> 
> > > I have now tested/deployed the patches on two production servers.
> > > 
> > >  Conclusion is: It should be safe to apply these patches.
> > > 
> > > See full report here:
> > >
http://people.netfilter.org/hawk/patches/htb_nohyst/production_test_results.html
> > > 
> > > We saw an increased number of interrupts on the test system, when
> > > enabling/disabling htb_hysteresis.
> > > 
> > >  This didn't show up on the production system.
> > > 
> > > I believe that the increased intr (on test system) is an artifact of the
> > > TCP download got less bursty and more smooth.
> > 
> > Which reminds me again, maybe after some time with hysteresis=off we 
> > could remove it altogether...
> > 
> > Sorry for the delay, I got some flu or what. On my smaller dualcore 
> > system there is also no noticeable (performance) impact.
> > 
> > I ACK Jesper's patches, thanks for the work and real-world testing!
> 
> I've applied Jesper's work to net-2.6, as it is primarily a bug
> fix of sorts and safe because a backwards compatible knob is
> provided just in case it does cause problems for people.
> 
> Thanks everyone!

I test this patch too, works fine on loaded system. No significant load
increase, works perfect.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

