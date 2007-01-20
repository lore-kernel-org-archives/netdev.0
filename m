From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on advanced routing and/or virtual routers.
Date: Sat, 20 Jan 2007 14:41:14 -0800
Message-ID: <45B29A8A.8010704@candelatech.com>
References: <45A27A78.8010200@candelatech.com> <20070108182327.GB19417@ventoux.cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:44703 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbXATWj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jan 2007 17:39:28 -0500
To: Brendan Cully <brendan@kublai.com>
In-Reply-To: <20070108182327.GB19417@ventoux.cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brendan Cully wrote:
> I started something like this a while ago (posted at
> <20051006215312.GD24375@zakopane.cs.ubc.ca> with a couple of replies
> by Thomas Graf, but I can't seem to find it in the archives) but then
> dropped the ball. It seems to work fairly well with a one-line kernel
> patch to allow route lookup before the local address check. Oh, and I
> didn't get traceroute working quite right either - I think there was
> some trick to finding the source address for the generated reply.
>
> I've got some info and code here: http://dsg.cs.ubc.ca/~brendan/remus/
>   
Using your scripts as a starting point,  and the one-liner kernel patch, 
I was able
to get it mostly working as well.  I also see trouble with traceroute 
and agree
that the problem is getting the right source-address in the ICMP and/or 
UDP response
packets.

I'm going to start digging into the kernel to see if there is some way I 
can force the
response out the same interface as it came in from, and also to force 
the source IP
to be the same as the port it is leaving on.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


