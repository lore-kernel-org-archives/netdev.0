From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Weak host model vs .interface down
Date: Fri, 11 Jun 2010 09:32:20 -0700
Message-ID: <4C126514.30905@hp.com>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:21033 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126Ab0FKQcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 12:32:23 -0400
In-Reply-To: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Linux uses the weak host model which makes the IP addresses part of the system
> rather than the interface. However consider this:
> 
> System A, eth0 connected to the network
> # > ifconfig eth0 192.168.1.16
> # > ifconfig eth1 192.168.1.17 down
> 
> System B
> # > ping 192.168.1.17
> PING 192.168.1.17 (192.168.1.17) 56(84) bytes of data.
> 64 bytes from 192.168.1.17: icmp_seq=1 ttl=64 time=0.618 ms
> 
> Isn't it a bit much to respond on 192.168.1.17 when its interface is down?

As you said at the beginning, the weak end system model presumes the IP address 
is part of the system.  Seems to me that means unless one removes the IP address 
from the system it is reasonable for the system to continue to respond to that 
IP address.  Regardless of what happens to any individual interface.

Now, I wouldn't expect it to continue to respond to 192.168.1.17 through eth1, 
but if eth0 is indeed connected to the same broadcast domain, given the 
following of the weak end-system model, continuing to respond seems consistent 
with enthusiasticaly following the weak end-system model.

rick jones
