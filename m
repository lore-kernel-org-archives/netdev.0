From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] udp: Don't save dst in udpv6_sendmsg()
Date: Sat, 24 Oct 2009 19:15:46 +0530
Message-ID: <OF34F531CA.C8E6FDAE-ON65257659.004B6782-65257659.004B99F8@in.ibm.com>
References: <20091023111336.4733.4901.sendpatchset@localhost.localdomain> <20091024.064010.145864194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:44873 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbZJXNqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:46:46 -0400
In-Reply-To: <20091024.064010.145864194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote on 10/24/2009 07:10:10 PM:
>
> > Performance: I ran netperf UDPv6 RR to use connected sockets.
> > Tested with a 70 min run, aggregate of 5 netperf runs for
> > each result.
>
> Who actually uses connected UDP sockets? :-)

Just something I found when running netperf RR tests, and the code is there
doing it anyway. Maybe I can drop doing this testing, but upto you.

Thanks,

- KK

