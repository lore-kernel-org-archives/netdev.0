From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sat, 21 Jan 2012 18:39:57 +0100
Message-ID: <m3fwf9gdjm.fsf@intrepid.localdomain>
References: <4F035BDE.5060409@candelatech.com>
	<20120103.145931.2188599484081157576.davem@davemloft.net>
	<4F035F2C.1000003@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:59730 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803Ab2AURtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jan 2012 12:49:40 -0500
In-Reply-To: <4F035F2C.1000003@candelatech.com> (Ben Greear's message of "Tue,
	03 Jan 2012 12:03:56 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com> writes:

>>> As far as I can tell, no other interfaces are auto-created
>>> in this manner.
>>
>> ip6tnl0 and sit0 do it too, just grep for alloc_netdev() under
>> net/{ipv4,ipv6}/
>
> So, no changing the behaviour?

Perhaps making it CONFIGurable would be safe enough, not that I like
CONFIG options for all tiny details (one may argue it's not a tiny
detail).

Haven't looked at the actual code.
-- 
Krzysztof Halasa
