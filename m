From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: [PATCH 0/2] Runtime configuration of HTB's HYSTERESIS option
Date: Thu, 15 Jun 2006 19:00:59 +1000
Message-ID: <1150362059.5578.13.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:39628 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1751339AbWFOJCC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 05:02:02 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@osdl.org>,
	Martin Devera <devik@cdi.cz>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The HTB qdisc has a compile time option, HTB_HYSTERESIS, 
that trades accuracy of traffic classification for CPU 
time.  These patches change hysteresis to be a runtime 
option under the control of "tc".

The effects of HYSTERESIS on HTB's accuracy are significant 
(see chapter 7, section 7.3.1, pp 69-70 in Jesper Brouer's
thesis: http://www.adsl-optimizer.dk/thesis/ ), whereas 
HTB's CPU usage on modern machines using broadband links 
is minimal.  Currently HYSTERESIS is on by default, and 
requires a kernel re-compile to change.  Altering it to 
be a runtime option will make life easier for the bulk of 
its users.

Further documentation on the patch and its usage can be
found here:
  http://www.stuart.id.au/russell/files/tc/tc-atm


This is a combined effort of Jesper Brouer and Russell 
Stuart, to get these patches into the upstream kernel.

Let the discussion start about what we need to change to 
get this upstream?

We see this as a feature enhancement, as such hope that 
it can be queued in davem's net-2.6.18.git tree. 

--
Regards
Russell Stuart and Jesper Brouer


