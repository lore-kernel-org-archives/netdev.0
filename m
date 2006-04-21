From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Cannot receive multicast packets
Date: Thu, 20 Apr 2006 20:05:27 -0700
Message-ID: <OFCD64E8C0.53CFCD68-ON88257157.000ED254-88257157.00107FAB@us.ibm.com>
References: <44482C8D.7010401@cloakmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:32916 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750946AbWDUDAR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 23:00:17 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3L30GHe001060
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 23:00:16 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3L2uYJi258406
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:56:34 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3L30Fqp028152
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 21:00:15 -0600
In-Reply-To: <44482C8D.7010401@cloakmail.com>
To: Andrew Athan <aathan_linux_net_1542@cloakmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew,

>  I did not 
> think the source IP was relevant to the matching code in linux, since 
> there are no source squelching socket options. 
> 
> There are no firewall rules active on this machine, and the packets are 
> definitely visible at the interface (see tcpdump output in my email).

        The source address is not relevant (other than potentially
for firewall rules), and I understand from your original mail that
they are arriving at the machine. The IP TTL is what I wanted to
know there; but "netstat -s" will normally tell you why a packet
was dropped, if it's arriving but not making it through the UDP/IP
stack (as is your case).

> I am going to try upgrading the kernel, and turning off the multicast 
> router kernel options as a next step.  But if you have any other ideas 
> at all, I'm all ears.

        "netstat -s" would be a good start. :-) tcpdump receiving a copy
of the packet does not mean UDP or IP won't drop it, but those drops
are counted.

                                                        +-DLS

