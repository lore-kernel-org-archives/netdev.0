From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Tue, 02 Jun 2009 02:32:39 -0700 (PDT)
Message-ID: <20090602.023239.182993491.davem@davemloft.net>
References: <1243907646.15854.16.camel@merlyn>
	<20090601.190228.75178984.davem@davemloft.net>
	<1243934530.8439.4.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, dada1@cosmosbay.com, nicolas.dichtel@6wind.com,
	fw@strlen.de, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754552AbZFBJci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:32:38 -0400
In-Reply-To: <1243934530.8439.4.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Tue, 02 Jun 2009 09:22:10 +0000

> On Mon, 2009-06-01 at 19:02 -0700, David Miller wrote:
>> And I even remember there are applications that use multicast and
>> a hop limit of zero explicitly to keep application traffic only on
>> the local subnet.  So any change like that proposed could break
>> things.
> 
> Are you thinking of multicast apps that explicitly set a hop limit, or Multicast
> Listener Discovery?  The hop limit specified for MLDv2 messages is one,
> not zero.

I am very much thinking of multicast apps that explicitly set a hop
limit.

The proof is in the pudding.  As mentioned in other parts of this
thread, we explicitly DO NOT allow a zero normal socket TTL option
but we DO allow a zero multicast TTL socket option to be set.
