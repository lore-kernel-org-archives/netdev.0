From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Mon, 16 Mar 2015 21:48:23 -0400
Message-ID: <550787E7.1030604@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>	<20150311081909.552e2052@grimm.local.home>	<55003666.3020100@oracle.com>	<20150311084034.04ce6801@grimm.local.home>	<55004595.7020304@oracle.com>	<20150311102636.6b4110a8@gandalf.local.home>	<55005491.5080809@oracle.com> <20150311105210.1855c95e@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150311105210.1855c95e@gandalf.local.home>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2015 10:52 AM, Steven Rostedt wrote:
>> > Could you try KASan for your use case and see if it potentially uncovers
>> > anything new?
> The problem is, I don't have a setup to build with the latest compiler.
> 
> I could build with my host compiler (that happens to be 4.9.2), but it
> would take a while to build, and is not part of my work flow.
> 
> 4.9.2 is very new, I think it's a bit premature to declare that the
> only way to test memory allocations is with the latest and greatest
> kernel.
> 
> But if kmemcheck really doesn't work anymore, than perhaps we should
> get rid of it.

Steven,


Since the only objection raised was the too-newiness of GCC 4.9.2/5.0, what
would you consider a good time-line for removal?

I haven't heard any "over my dead body" objections, so I guess that trying
to remove it while no distribution was shipping the compiler that would make
it possible was premature.

Although, on the other hand, I'd be happy if we can have a reasonable date
(that is before my kid goes to college), preferably even before the next
LSF/MM so that we could have a mission accomplished thingie with a round
of beers and commemorative t-shirts.


Thanks,
Sasha
