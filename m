From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 15:12:37 +0200
Message-ID: <18031.60741.695897.572432@robur.slu.se>
References: <466DEF9D.9070509@trash.net>
	<1181615384.4071.121.camel@localhost>
	<466E9DF2.9010505@trash.net>
	<20070612.140240.00078635.davem@davemloft.net>
	<466F0D74.5030308@trash.net>
	<1181714168.4758.57.camel@debian.sh.intel.com>
	<1181737935.4050.87.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>, Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:47667 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726AbXFMNMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 09:12:47 -0400
In-Reply-To: <1181737935.4050.87.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:

 > The key arguement i make (from day one actually) is to leave the
 > majority of the work to the driver.
 > My view of wireless WMM etc is it is a different media behavior
 > (compared to wired ethernet) which means a different view of strategy
 > for when it opens the valve to allow in more packets. 802.11 media has
 > embedded signalling which is usable. Guy Cohen gave a good use case
 > which i responded to. Do you wanna look at that and respond?

 Hello,

 Haven't got all details. IMO we need to support some "bonding-like" 
 scenario too. Where one CPU is feeding just one TX-ring. (and TX-buffers
 cleared by same CPU). We probably don't want to stall all queuing when
 when one ring is full. 
 
 The scenario I see is to support parallelism in forwarding/firewalling etc.
 For example when RX load via HW gets split into different CPU's and for 
 cache reasons we want to process in same CPU even with TX.

 If RX HW split keeps packets from the same flow on same CPU we shouldn't
 get reordering within flows.

 Cheers
						--ro
 
