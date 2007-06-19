From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 19:35:45 +0200
Message-ID: <18040.5105.715624.286924@robur.slu.se>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	<1181216629.4064.22.camel@localhost>
	<20070619132148.GA32078@2ka.mipt.ru>
	<20070619133333.GA19667@2ka.mipt.ru>
	<20070619140038.GA13629@2ka.mipt.ru>
	<1182270529.4968.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:36147 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758724AbXFSRkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 13:40:52 -0400
In-Reply-To: <1182270529.4968.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:

 > What is your kernel config in regards to HRES timers? Robert mentioned
 > to me that the clock source maybe causing issues with pktgen (maybe even
 > qos). Robert, insights?

 pktgen heavily uses gettimeofday. I was using tsc as clock source with 
 our opterons in the lab. In late 2.6.20 gettimeofday was changed so tsc 
 couldn't be used on opterons (pktgen at least). 

 To give you an example w.intel's 82571EB we could send 1.488 Mpps using tsc 
 but with hpet only 400 kpps.

 But Evgeniy is most likely using the same clocksource both for the mainline 
 and batch tests so there must be something different...


 Cheers.
					--ro
