From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 15:00:01 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1210181458560.21297@uplift.swm.pp.se>
References: <507F38D4.102@genband.com> <m3vce83w1y.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:60053 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068Ab2JRNAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 09:00:04 -0400
In-Reply-To: <m3vce83w1y.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Oct 2012, Benny Amorsen wrote:

> Chris Friesen <chris.friesen@genband.com> writes:
>
>> 7) client waits for response from server, and waits forever or until
>> keepalive expires
>
> Please don't fix that. I sometimes move my laptop from one ethernet
> socket to another. During the move I lose my DHCP-assigned IP address.

Would you mind if it was user configurable?

> I do not want to lose my SSH sessions too.

Would you mind if the TCP retransmit timers were severely lowered upon 
reconnection so your TCP sessions started working quicker? Or you don't 
see this problem at all?

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
