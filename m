From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Thu, 27 Aug 2009 00:57:36 +0200
Message-ID: <20090826225736.GA31970@elte.hu>
References: <20090820201919.GA20750@localhost.localdomain> <20090821001421.214a560b.billfink@mindspring.com> <20090821152341.GA2998@localhost.localdomain> <20090826031057.375303c9.billfink@mindspring.com> <20090826110013.GA10816@hmsreliant.think-freely.org> <20090826180811.GB10816@hmsreliant.think-freely.org> <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826200119.GD10816@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Fr?d?ric Weisbecker <fweisbec@gmail.com>,
	Bill Fink <billfink@mindspring.com>,
	Linux Network Developers <netdev@vger.kernel.org>,
	brice@myri.com, gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:32865 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751843AbZHZW5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 18:57:47 -0400
Content-Disposition: inline
In-Reply-To: <20090826200119.GD10816@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Neil Horman <nhorman@tuxdriver.com> wrote:

> > Is there anything in it that cannot be expressed in terms of 
> > TRACE_EVENT()?
>
> As David noted in my previous posting, no, I don't intend to 
> change this. [...]

Well, this change lacks the ack of the maintainers of kernel/trace/* 
for the technical reasons outlined in the (many...) mails sent on 
this topic, so for the .32 networking tree to be properly pushable 
to Linus you'll have to come up with a better answer than "I don't 
intend to change this".

David, i tried to help but i really dont have time to deal with an 
inefficient workflow like this. Two weeks ago you committed a 
clearly broken patch to the tracing code, it had bugs, it was 
objected to because it does the wrong thing altogether and Neil 
refuses to fix it and i'm supposed to convince Neil what the right 
solution is?

That's not how maintenance is supposed to work, it's utterly not 
scalable. Please deal with it one way or another.

Thanks,

	Ingo
