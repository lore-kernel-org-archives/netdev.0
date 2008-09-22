From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 19:00:08 -0400
Message-ID: <48D82378.4000306@redhat.com>
References: <20080922.040912.193700258.davem@davemloft.net>	<20080922203042.GY25711@one.firstfloor.org>	<48D81A95.5080207@redhat.com> <20080922.152615.215876787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33283 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753606AbYIVW7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 18:59:44 -0400
In-Reply-To: <20080922.152615.215876787.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Chris Snook <csnook@redhat.com>
> Date: Mon, 22 Sep 2008 18:22:13 -0400
> 
>> How horrendous of a layering violation would it be to attach TCP
>> performance parameters (either user-supplied or based on interface
>> stats) to route table entries, like route metrics but intended to
>> guide TCP autotuning?  It seems like it shouldn't be that hard to
>> teach TCP that it doesn't need to optimize my lo connections much,
>> and that it should be optimizing my eth0 subnet connections for
>> lower latency and higher bandwidth than the connections that go
>> through my gateway into the great beyond.
> 
> We already do this for other TCP connection parameters, and I tend to
> think these delack/ato values belong there too.
> 
> If we add a global knob, people are just going to turn it on even if
> they are also connected to the real internet on the system rather than
> only internal networks they completely control.
> 
> That tends to cause problems.  It gets an entry on all of these bogus
> "Linux performance tuning" sections administrators read from the
> various financial messaging products.  So everyone does it without
> thinking and using their brains.

I agree 100%.  Could you please point me to an example of a connection parameter 
that gets tuned and cached this way, so I can experiment with it?

-- Chris
