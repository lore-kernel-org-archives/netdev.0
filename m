From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [e1000]:  flow control on by default - good idea really?
Date: Wed, 5 Jul 2006 18:57:47 +0200
Message-ID: <17579.61323.809672.695357@robur.slu.se>
References: <1152033116.5276.22.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Ben Greear <greearb@candelatech.com>, john.ronciak@intel.com,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:35214 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S964893AbWGEQ7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 12:59:15 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152033116.5276.22.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:

 > The default setup on the e1000 has rx flow control turned on.
 > I was sending at wire rate gige from the device - which is about
 > 1.48Mpps. The e1000 was in turn sending me flow control packets
 > as per default/expected behavior. Unfortunately, it was sending
 > a very large amount of packets. At one point i was seeing upto
 > 1Mpps and on average, the flow control packets were consuming
 > 60-70% of the bandwidth. Even when i fixed this behavior to act
 > properly, allowing flow control on consumed up to 15% of the bandwidth. 
 > Clearly, this is a bad thing. Yes, the device in the first instance was
 > at fault. But i have argued in the past that NAPI does just fine without
 > flow control being turned on, so even chewing 5% of bandwidth on flow
 > control is a bad thing..

 Interesting numbers. But one can argue that if there were no control packets 
 there would be data packets sent and dropped instead. But I'll agree with you
 as the flow control seems hard to monitor and tune and takes debugging
 down to link and chiplevels. Much easier and robust just to read the 
 dropped packet counter on the box that couldn't handle the load rather than 
 following secret flow control packets somewhere else and try to figure out 
 whats going on. 
  
 > As a compromise, can we declare flow control as an advanced feature
 > and turn it off by default? People who feel it is valuable and know
 > what they are doing can turn it off.

 At least for NAPI-scheme drivers.

 > If you want more details just shoot.

 Cheers.
						--ro
