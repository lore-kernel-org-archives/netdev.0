From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and
 intro.
Date: Tue, 27 Nov 2007 22:12:39 -0600
Message-ID: <C37246D7.1F282%tom@opengridcomputing.com>
References: <200711281227.50136.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<sam@ravnborg.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:21163 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436AbXK1Emf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 23:42:35 -0500
In-Reply-To: <200711281227.50136.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/27/07 7:27 PM, "Rusty Russell" <rusty@rustcorp.com.au> wrote:

> On Tuesday 27 November 2007 16:35:42 Tom Tucker wrote:
>> On Tue, 2007-11-27 at 15:49 +1100, Rusty Russell wrote:
>> Explicitly documenting what comprises the kernel API (external,
>> supported) and what comprises the kernel implementation (internal, not
>> supported).
> 
> But the former is currently an empty set.
> 

Yes, I overstated this.

>> - making it obvious to developers when they are binding their
>> implementation to a particular kernel release
> 
> See, there's your problem.  All interfaces can, and will, change.  You're
> always binding yourself to a particular release.
> 

Absolutely in the limit. But there are many bits of code that work quite
nicely from release to release because they use services that live in the
smooth water in the wake of the Linux head.

I think defining that smooth water has merit. I also think that it would be
nice to limit the scope of module externs to avoid polluting the global
namespace. I'm not sure that this particular patch reaches these goals, but
it prompted me to comment.

> So you're not proposing we mark what's not stable, you're arguing that we
> create a subset which is stable.
> 

Well, this is an interesting question. The answer is I think both are
important. It would be nice (and arguably necessary long term) to limit the
scope of externs. This can be accomplished with name spaces "I want bob's
implementation of read."

I think it also has value to define interfaces that are considered stable
(but not inviolate) to allow developers to make better informed decisions
when choosing interfaces. Having this info explicit in the code seems
logical to me.

> That's an argument we're not (yet) having.
> 

Yeah, maybe I'm off in the weeds on this one...

Tom

> Cheers,
> Rusty.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


