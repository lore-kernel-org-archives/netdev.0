From: Martin Devera <devik@cdi.cz>
Subject: Re: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Sat, 14 Jun 2008 11:18:00 +0200
Message-ID: <48538CC8.9020706@cdi.cz>
References: <1212501803.13164.27.camel@localhost.localdomain>	 <48469323.8000506@cdi.cz> <1212589713.13164.75.camel@localhost.localdomain> <1213264875.29292.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wifcom.cz ([89.185.251.8]:43350 "EHLO wifcom.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758925AbYFNJSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 05:18:05 -0400
In-Reply-To: <1213264875.29292.17.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have now tested/deployed the patches on two production servers.
> 
>  Conclusion is: It should be safe to apply these patches.
> 
> See full report here:
> http://people.netfilter.org/hawk/patches/htb_nohyst/production_test_results.html
> 
> We saw an increased number of interrupts on the test system, when
> enabling/disabling htb_hysteresis.
> 
>  This didn't show up on the production system.
> 
> I believe that the increased intr (on test system) is an artifact of the
> TCP download got less bursty and more smooth.

Which reminds me again, maybe after some time with hysteresis=off we 
could remove it altogether...

Sorry for the delay, I got some flu or what. On my smaller dualcore 
system there is also no noticeable (performance) impact.

I ACK Jesper's patches, thanks for the work and real-world testing!

Martin
