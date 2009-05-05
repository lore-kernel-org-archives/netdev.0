From: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Tue, 5 May 2009 17:21:44 +0930
Message-ID: <20090505172144.98a63672.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
References: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<87tz41gqr0.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:43608 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332AbZEEHvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 03:51:49 -0400
In-Reply-To: <87tz41gqr0.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi,

Thanks for your interest.

On Mon, 04 May 2009 11:29:55 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> Mark Smith <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> writes:
> > +
> > +4. Security
> > +
> > +ECTP was designed in the early 1980s, when protocol security was less of
> > +a concern than it is now. Consequently, there are some features of the
> > +protocol which could be abused for nefarious purposes. By default, this
> > +implementation attempts to avoid participating in them. These features
> > +could be useful for some test cases thought, so they can be enabled if
> > +required.
> 
> I think security would need quite a bit more discussion. Opening new
> DOS this way sounds quite worrying, especially since this is a
> extremly obscure protocol that likely most admins don't know much
> about.
> 
> Is this suspencible to ping to broadcast flood replication for example?
> 

No it isn't. Forward addresses in forward messages (specifying the next
hop on the path) are prohibited by the protocol specification from
being multicast or broadcast addresses.

> Safest would probably be default to off.
> 

In my implementation, this unicast forward address check can't be
switched off.

Some of the other security mitigation mechanisms I've implemented
weren't really necessary, however I felt that it'd be good to ensure
this implementation was as good a "citizen" as possible.

Thanks,
Mark.
