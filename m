From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] udp: Don't save dst in udpv6_sendmsg()
Date: Sat, 24 Oct 2009 06:49:15 -0700 (PDT)
Message-ID: <20091024.064915.76607526.davem@davemloft.net>
References: <20091023111336.4733.4901.sendpatchset@localhost.localdomain>
	<20091024.064010.145864194.davem@davemloft.net>
	<OF34F531CA.C8E6FDAE-ON65257659.004B6782-65257659.004B99F8@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32837
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753559AbZJXNsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:48:52 -0400
In-Reply-To: <OF34F531CA.C8E6FDAE-ON65257659.004B6782-65257659.004B99F8@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Sat, 24 Oct 2009 19:15:46 +0530

> David Miller wrote on 10/24/2009 07:10:10 PM:
>>
>> > Performance: I ran netperf UDPv6 RR to use connected sockets.
>> > Tested with a 70 min run, aggregate of 5 netperf runs for
>> > each result.
>>
>> Who actually uses connected UDP sockets? :-)
> 
> Just something I found when running netperf RR tests, and the code is there
> doing it anyway. Maybe I can drop doing this testing, but upto you.

Eric Dumazet or someone else made comments recently about how
nobody uses connected UDP sockets.

And if someone actually does, they can complain and we can
go back to looking into it :-)
