From: "Christopher Friesen" <cfriesen@nortel.com>
Subject: Re: address pingable with interface down
Date: Wed, 10 May 2006 17:06:11 -0600
Message-ID: <446271E3.9070208@nortel.com>
References: <20060510194818.GB4460@junkers.homelinux.net> <20060510.130012.128043400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jadevree@mtu.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:10234 "EHLO
	zcars04e.nortel.com") by vger.kernel.org with ESMTP id S965066AbWEJXGQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 19:06:16 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060510.130012.128043400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Jon DeVree <jadevree@mtu.edu>

>>I've noticed in the past that the address owned by an interface is
>>still pingable after that interface is brought down.

> People bring this up all the time and this behavior is
> intentional.

> This is becoming a serious FAQ and very tiresome to explain over and
> over again.

Maybe the fact that so may people ask about or are surprised by it is a 
sign that it is counter-intuitive and should perhaps be more fully 
documented?

The fact that "ifconfig" or "ip addr" show IP addresses as specifically 
associated with individual ethernet links may contribute to this 
problem--it sure makes it look like the IP address is an attribute of 
the link rather than the host.

Chris
