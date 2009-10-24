From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] udp: Don't save dst in udpv6_sendmsg()
Date: Sat, 24 Oct 2009 19:30:21 +0530
Message-ID: <OF5DC88D9B.31D2C6B4-ON65257659.004CC0D9-65257659.004CEFFC@in.ibm.com>
References: <20091023111336.4733.4901.sendpatchset@localhost.localdomain>	<20091024.064010.145864194.davem@davemloft.net>
	<OF34F531CA.C8E6FDAE-ON65257659.004B6782-65257659.004B99F8@in.ibm.com> <20091024.064915.76607526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:40382 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737AbZJXOBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 10:01:30 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9OE1XaK030049
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 19:31:33 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9OE1WZa2388194
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2009 19:31:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9OE1W1t020608
	for <netdev@vger.kernel.org>; Sun, 25 Oct 2009 01:01:32 +1100
In-Reply-To: <20091024.064915.76607526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 10/24/2009 07:19:15 PM:

>
> >> Who actually uses connected UDP sockets? :-)
> >
> > Just something I found when running netperf RR tests, and the code is
there
> > doing it anyway. Maybe I can drop doing this testing, but upto you.
>
> Eric Dumazet or someone else made comments recently about how
> nobody uses connected UDP sockets.
>
> And if someone actually does, they can complain and we can
> go back to looking into it :-)

Agreed. Please drop it.

Thanks,

- KK

