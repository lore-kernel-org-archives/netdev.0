From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 01 Jun 2009 19:02:28 -0700 (PDT)
Message-ID: <20090601.190228.75178984.davem@davemloft.net>
References: <4A242161.3010609@cosmosbay.com>
	<4A242418.1090804@hp.com>
	<1243907646.15854.16.camel@merlyn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, dada1@cosmosbay.com, nicolas.dichtel@6wind.com,
	fw@strlen.de, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754531AbZFBCC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 22:02:28 -0400
In-Reply-To: <1243907646.15854.16.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Mon, 01 Jun 2009 20:54:06 -0500

> On Mon, 2009-06-01 at 14:55 -0400, Brian Haley wrote: 
>> I don't know if that difference
>> in behavior is desired.  Do we know how any other OSes behave?
> 
> FWIW, the random BSD flavors I have on hand all check hop limit when
> forwarding, but not when processing local ingress traffic.
> 
> Also FWIW, as I remember, the TAHI tests only check hop limit behavior
> on forwarded traffic.

And this is the behavior that makes the most sense to me.

The local system is "accounted for" in the hop limit by the previous
hop system.  No other behavior makes any sense.

And I even remember there are applications that use multicast and
a hop limit of zero explicitly to keep application traffic only on
the local subnet.  So any change like that proposed could break
things.

